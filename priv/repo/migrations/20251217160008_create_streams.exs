defmodule RtmpServer.Repo.Migrations.CreateStreams do
  use Ecto.Migration

  def change do
    create table(:streams) do
      add :stream_id, :string
      add :stream_key, :string
    end
  end
end
