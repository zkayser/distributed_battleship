defmodule Coerce do
  def string(nil),                         do: {:error, "can not make it a string"}
  def string(value) when is_list(value),   do: {:ok, to_string(value)}
  def string(value) when is_atom(value),   do: {:ok, Atom.to_string(value)}
  def string(value) when is_binary(value), do: {:ok, value}
  def string(_value),                      do: {:error, "can not make it a string"}
end
