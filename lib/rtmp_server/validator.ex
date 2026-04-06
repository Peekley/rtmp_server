defmodule RtmpServer.Validator do
  @behaviour Membrane.RTMPServer.Handler

  alias RtmpServer.{Repo, Stream}

  @impl true
  def handle_new_client(client_ref, publish_path, _connect_info) do
    case decode_stream_key(publish_path) do
      {:ok, {stream_id, stream_key}} ->
        if Repo.get_by(Stream, stream_id: stream_id, stream_key: stream_key) do
          # Send stream_id to the future pipeline (we'll handle this via a registry or message)
          {:ok, pipeline} = DynamicSupervisor.start_child(RtmpServer.PipelineSupervisor, {RtmpServer.StreamPipeline, [client_ref: client_ref, stream_id: stream_id]})
          {:accept, pipeline}
        else
          {:reject, :invalid_stream_key}
        end

      {:error, _} ->
        {:reject, :invalid_path}
    end
  end

  @impl true
  def handle_client_disconnected(_client_ref, _reason), do: :ok

  defp decode_stream_key(publish_path) do
    # publish_path is the stream key part, e.g., the base32 key for /live/<base32>
    case Base32.decode(publish_path) do
      {:ok, decoded} ->
        case String.split(decoded, ":", parts: 2) do
          [stream_id, stream_key] -> {:ok, {stream_id, stream_key}}
          _ -> {:error, :invalid_format}
        end
      _ -> {:error, :invalid_base32}
    end
  end
end
