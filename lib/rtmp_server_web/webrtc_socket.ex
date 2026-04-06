defmodule RtmpServerWeb.WebRTCSocket do
  use Phoenix.Socket
  alias RtmpServer.{Repo, Stream}

  channel "webrtc:*", RtmpServerWeb.WebRTCChannel

  @impl true
  def connect(%{"base32_key" => base32_key}, socket, _connect_info) do
    case decode_stream_key(base32_key) do
      {:ok, {stream_id, stream_key}} ->
        if Repo.get_by(Stream, stream_id: stream_id, stream_key: stream_key) do
          {:ok, assign(socket, stream_id: stream_id)}
        else
          :error
        end
      {:error, _} ->
        :error
    end
  end

  @impl true
  def id(_socket), do: nil

  defp decode_stream_key(base32_key) do
    case Base32.decode(base32_key) do
      {:ok, decoded} ->
        case String.split(decoded, ":", parts: 2) do
          [stream_id, stream_key] -> {:ok, {stream_id, stream_key}}
          _ -> {:error, :invalid_format}
        end
      {:error, _} -> {:error, :invalid_base32}
    end
  end
end
