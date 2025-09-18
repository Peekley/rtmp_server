defmodule RtmpServerTest do
  use ExUnit.Case
  doctest RtmpServer

  test "greets the world" do
    assert RtmpServer.hello() == :world
  end
end
