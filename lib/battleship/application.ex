defmodule Battleship.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    Logger.info "Starting Battleships"

    Commander.start()

    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Battleship.Worker.start_link(arg)
      #{Battleship.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Battleship.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
