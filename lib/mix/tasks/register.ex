defmodule Mix.Tasks.Battleship.Register do
  use Mix.Task

  @shortdoc "A player registers for the battleships game"

  def run(name) when length(name) == 0 do
    IO.puts "usage: register <name>" 
  end
  def run(name) do
    with connected      <- connect(),
         {:ok, pid}     <- lookup_service(connected),
         {:ok, message} <- register(pid, name)
    do
      IO.puts message
    else
      {:error, message} -> IO.puts message
      message           -> IO.inspect message
    end
  end

  def connect() do
    {:ok, hostname} = :inet.gethostname
    Node.connect(:"commander@#{hostname}")
  end

  def lookup_service(:ignored) do
    {:error, "Battleships is not running"}
  end
  def lookup_service(false) do
    {:error, "Battleships is not running"}
  end
  def lookup_service(true) do
    :timer.sleep(1000)
    pid = :global.whereis_name(:players)
    {:ok, pid}
  end

  def register(pid, name) do
    Players.register(pid, name)
  end
end
