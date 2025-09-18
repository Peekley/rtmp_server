defmodule RtmpServer.Validator do
  @behaviour Membrane.RTMP.MessageValidator

  alias RtmpServer.Repo
  alias RtmpServer.Stream

  defstruct pipeline_pid: nil

  @impl true
  def validate(validator, message, state) do
    case message do
      {:publish, _app, stream_name} ->
        [stream_id | [stream_key]] = String.split(stream_name, "/")
        if Repo.exists?(Stream, id: stream_id, stream_key: stream_key) do
          send(validator.pipeline_pid, {:stream_id, stream_id})
          {:valid, state}
        else
          :invalid
        end

      _ ->
        {:valid, state}
    end
  end
end
