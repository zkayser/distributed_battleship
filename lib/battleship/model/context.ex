defmodule Context do

  defstruct tick_count: 0,
            tick_rate_ms: 1000,
            node_self: Node.self(),
            node_cookie: Node.get_cookie()

  def new() do
    Map.from_struct %__MODULE__{}
  end
end
