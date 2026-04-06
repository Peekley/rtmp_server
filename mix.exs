defmodule RtmpServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :rtmp_server,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {RtmpServer.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:membrane_core, "~> 1.2"},
      {:membrane_rtmp_plugin, "~> 0.29"},
      {:membrane_mp4_plugin, "~> 0.36"},
      {:membrane_file_plugin, "~> 0.17"},
      {:membrane_webrtc_plugin, "~> 0.26"},
      {:membrane_http_adaptive_stream_plugin, "~> 0.20"},
      {:ecto_sql, "~> 3.13"},
      {:postgrex, "~> 0.21.1"},
      {:bandit, "~> 1.5"},  # For serving HLS via HTTPs
      {:dotenv, "~> 3.1"},
      {:phoenix, "~> 1.7"},  # For WebSocket endpoint
      {:jason, "~> 1.4"},    # For JSON signaling
      {:base32, "~> 1.0"}  # New: For base32 encoding/decoding
    ]
  end
end
