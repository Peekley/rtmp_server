defmodule RtmpServer.Repo do
  use Ecto.Repo,
    otp_app: :rtmp_server,
    adapter: Ecto.Adapters.Postgres
end
