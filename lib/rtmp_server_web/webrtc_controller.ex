defmodule RtmpServerWeb.WebRTCController do
  use Phoenix.Controller,
    formats: [:json]
  alias RtmpServer.{Repo, Stream}

  def connect(conn, %{"base32_key" => base32_key}) do
    case decode_stream_key(base32_key) do
      {:ok, {stream_id, stream_key}} ->
        if Repo.get_by(Stream, stream_id: stream_id, stream_key: stream_key) do
          conn
          |> put_status(:ok)
          |> json(%{status: "ok", socket_path: "/webrtc/socket/#{base32_key}"})
        else
          conn
          |> put_status(:unauthorized)
          |> json(%{error: "Invalid stream key"})
        end
      {:error, _} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid base32 key format"})
    end
  end

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
