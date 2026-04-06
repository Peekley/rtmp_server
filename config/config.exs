import Config

config :rtmp_server,
  ecto_repos: [RtmpServer.Repo]

config :rtmp_server, RtmpServer.Repo,
  username: System.get_env("DATABASE_USERNAME", "postgres"),
  password: System.get_env("DATABASE_PASSWORD", "postgres"),
  database: System.get_env("DATABASE_NAME", "rtmp_server_dev"),
  hostname: System.get_env("DATABASE_HOST", "localhost"),
  show_sensitive_data_on_connection_error: true,
  pool_size: 10


# Phoenix config for WebSocket and static HLS
config :phoenix, :json_library, Jason

config :rtmp_server, RtmpServerWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: String.to_integer(System.get_env("HLS_PORT", "80"))],
  url: [host: "localhost"],
  check_origin: false,
  secret_key_base: System.get_env("SECRET_KEY_BASE", "your_secret_key_base_here"),  # Generate with `mix phx.gen.secret`
  pubsub_server: RtmpServer.PubSub
