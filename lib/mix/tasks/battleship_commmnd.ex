defmodule Battleship.Command do

  def puts(commander_ip, service, command_function) do
    IO.inspect command(commander_ip, service, command_function)
  end

  def command(commander_ip, service, command_function) do
    with connected      <- connect(commander_ip),
         {:ok, pid}     <- lookup_service(service, connected)
    do
      {:ok, message} = command_function.(pid)
      message
    else
      {:error, message} -> message
      message           -> message
    end
  end

  defp connect(commander_ip) do
    Node.connect(:"commander@#{commander_ip}")
  end

  defp lookup_service(_, :ignored) do
    {:error, "Battleships is not running: ignored"}
  end
  defp lookup_service(_, false) do
    {:error, "Battleships is not running: false"}
  end
  defp lookup_service(service, true) do
    :timer.sleep(1000)
    the_pid(service, :global.whereis_name(service))
  end

  defp the_pid(service, :undefined) do
    {:error, "#{service} service not found"}
  end
  defp the_pid(_ervice, pid) do
    {:ok, pid}
  end
end

