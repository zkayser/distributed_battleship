defmodule DistributedBattleship.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    Logger.info "Starting Distributed Battleships"

    spawn_link(GameCommander, :start, [])

    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: DistributedBattleship.Worker.start_link(arg)
      #{DistributedBattleship.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DistributedBattleship.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
