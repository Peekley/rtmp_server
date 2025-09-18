defmodule RtmpServer.HlsServer do
  use Plug.Router

  plug Plug.Static, at: "/hls", from: "hls"
  plug :match
  plug :dispatch

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
