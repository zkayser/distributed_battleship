defmodule Battleship.Command do

  def puts(service, command_function) do
    IO.inspect command(service, command_function)
  end

  def command(service, command_function) do
    with connected      <- connect(),
         {:ok, pid}     <- lookup_service(service, connected)
    do
      {:ok, message} = command_function.(pid)
      message
    else
      {:error, message} -> message
      message           -> message
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
    the_pid(service, :global.whereis_name(service))
  end

  defp the_pid(service, :undefined) do
    {:error, "#{service} service not found"}
  end
  defp the_pid(_ervice, pid) do
    {:ok, pid}
  end
end

