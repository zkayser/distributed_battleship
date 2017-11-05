defmodule OceanTest do
  use ExUnit.Case

  setup() do
    pid = Ocean.start()

    on_exit(fn -> Ocean.stop(pid) end)

    [pid: pid]
  end

  test "stop the service" do
    Ocean.stop()
  end

 
end

