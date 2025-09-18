defmodule RtmpServer.Stream do
  use Ecto.Schema

  schema "streams" do
    field :id, :string
    field :stream_key, :string
  end
end
