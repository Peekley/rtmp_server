defmodule RtmpServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Dotenv.load()

    children = [
      # Starts a worker by calling: RtmpServer.Worker.start_link(arg)
      # {RtmpServer.Worker, arg}
      RtmpServer.Repo,
      {DynamicSupervisor, strategy: :one_for_one, name: RtmpServer.PipelineSupervisor},
      {Membrane.RTMPServer,
        port: String.to_integer(System.get_env("RTMP_PORT", "1935")),
        handler: RtmpServer.Validator,
        app_name: "live"  # Matches rtmp://host/live/<base32_key>
      },
      # RTMPS if needed: similar with ssl options
      {Phoenix.PubSub, name: RtmpServer.PubSub},
      RtmpServerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RtmpServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
