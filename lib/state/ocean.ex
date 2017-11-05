defmodule Ocean do
  def start() do
    pid = spawn_link(Ocean.Server, :loop, [:continue, %{}])

    :global.register_name(:ocean, pid)

    pid
  end

  def stop(), do: stop(:global.whereis_name(:ocean))
  def stop(pid) do
    send pid, :stop
  end
end

defmodule Ocean.Server do
  require Logger

  def loop(:stop, _) do end
  def loop(:continue, state) do
    {next, state } = receive do
      command -> run(command, state)
    end

    loop(next, state)
  end

  defp run(command, state) do
    Logger.info("Ocean command #{command} : #{inspect state}")
  end

end
