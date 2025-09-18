import Config

config :rtmp_server, RtmpServer.Repo,
  username: System.get_env("DATABASE_USERNAME", "postgres"),
  password: System.get_env("DATABASE_PASSWORD", "postgres"),
  database: System.get_env("DATABASE_NAME", "rtmp_server_dev"),
  hostname: System.get_env("DATABASE_HOST", "localhost"),
  show_sensitive_data_on_connection_error: false,
  pool_size: 10
