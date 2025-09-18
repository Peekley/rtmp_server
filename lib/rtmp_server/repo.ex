defmodule RtmpServer.Repo do
  use Ecto.Repo,
    otp_app: :rtmp_server,
    adatper: Ecto.Adapters.Postgres
end
