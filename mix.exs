defmodule RtmpServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :application,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:membrane_core, "~> 1.2"},
      {:membrane_rtmp_plugin, "~> 0.28"},
      {:membrane_hls_plugin, "~> 1.1.4"},
      {:membrane_mp4_plugin, "~> 0.36"},
      {:membrane_file_plugin, "~> 0.17"},
      {:ecto_sql, "~> 3.12"},
      {:postgrex, ">= 0.18.0"},
      {:bandit, "~> 1.5"},
      {:dotenv, "~> 3.1"}
    ]
  end
end
