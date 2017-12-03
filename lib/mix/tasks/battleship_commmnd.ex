defmodule Battleship.Command do

  def command(service, command_function) do
    with connected      <- connect(),
         {:ok, pid}     <- lookup_service(service, connected)
    do
      {:ok, message} = command_function.(pid)
      IO.inspect message
    else
      {:error, message} -> IO.puts message
      message           -> IO.inspect message
    end
  end

  defp connect() do
    {:ok, hostname} = :inet.gethostname
    Node.connect(:"commander@#{hostname}")
  end

  defp lookup_service(_, :ignored) do
    {:error, "Battleships is not running: ignored"}
  end
  defp lookup_service(_, false) do
    {:error, "Battleships is not running: false"}
  end
  defp lookup_service(service, true) do
    :timer.sleep(1000)
    the_pid(:global.whereis_name(service))
  end

  defp the_pid(:undefined) do
    {:error, "players service not found"}
  end
  defp the_pid(pid) do
    {:ok, pid}
  end
end

