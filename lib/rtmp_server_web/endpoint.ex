defmodule RtmpServerWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :rtmp_server

  # WebSocket for WebRTC signaling
  socket "/webrtc/socket", RtmpServerWeb.WebRTCSocket,
    websocket: true,
    longpoll: false

  # Serve HLS files statically from the "hls" directory at /hls
  plug Plug.Static,
    at: "/hls",
    from: "hls",                 # relative to project root, or use absolute path
    gzip: true,
    headers: %{"access-control-allow-origin" => "*"}  # Optional: allow CORS for players

  # Optional: serve other static assets if needed (e.g., favicon)
  # plug Plug.Static,
  #   at: "/",
  #   from: :rtmp_server,
  #   gzip: false,
  #   only: ~w(favicon.ico robots.txt)

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug RtmpServerWeb.Router
end
