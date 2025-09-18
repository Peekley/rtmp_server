defmodule RtmpServer.Application do
  use Application

  def start(_type, _args) do
    # Load .env file
    Dotenv.load()

    children = [
      RtmpServer.Repo,
      {RtmpServer.RtmpListener, port: String.to_integer(System.get_env("RTMP_PORT", "1935"))},
      {Bandit, plug: RtmpServer.HlsServer, scheme: :http, port: String.to_integer(System.get_env("HLS_PORT", "8800"))}
    ]

    opts = [strategy: :one_for_one, name: RtmpServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
