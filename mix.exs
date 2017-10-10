defmodule Squest.Mixfile do
  use Mix.Project

  def project do
    [
      app: :squest,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Squest.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:uuid, "~> 1.1"},
      {:gen_stage, "~> 0.12.2"},
      {:erlcloud, "~> 2.2.15"}
    ]
  end
end
