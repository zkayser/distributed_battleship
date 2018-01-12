defmodule Battleship.Mixfile do
  use Mix.Project

  def project do
    [
      app: :battleship,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      # Prevent the applications from starting during ExUnit testing.
      aliases: [test: "test --no-start"]
    ]
  end


  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Battleship.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mix_test_watch, "~> 0.3", only: :dev, runtime: false},
    ]
  end
end
