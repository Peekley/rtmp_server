defmodule RtmpServer.RtmpListener do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(port: port) do
    {:ok, listen_socket} = :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true])
    Task.start_link(fn -> accept_loop(listen_socket) end)
    {:ok, %{listen_socket: listen_socket}}
  end

  defp accept_loop(listen_socket) do
    {:ok, socket} = :gen_tcp.accept(listen_socket)
    {:ok, _pid} = Membrane.Pipeline.start_link(RtmpServer.StreamPipeline, socket)
    accept_loop(listen_socket)
  end
end
