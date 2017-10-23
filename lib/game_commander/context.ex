defmodule Context do

  defstruct tick_count: 0,
            tick_rate_ms: 1000,
            node_self: Node.self(),
            node_cookie: Node.get_cookie()

  def new() do
  	%__MODULE__{}
  end
end