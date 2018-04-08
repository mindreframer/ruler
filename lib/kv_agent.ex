defmodule Ruler.KVAgent do
  # https://elixir-lang.org/getting-started/mix-otp/agent.html
  use Agent

  @initialstate %{
    "bindings" => %{},
    "templates" => %{},
    "functions" => %{}
  }
  @doc """
  Starts a new KVAgent.
  """
  def start_link(_opts) do
    Agent.start_link(fn -> @initialstate end)
  end

  @doc """
  Gets a value from the `bucket` by `key`.
  """
  def get(pid, path) do
    Agent.get(pid, &get_in(&1, path))
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket`.
  """
  def set(pid, path, value) do
    if length(path) > 1 and get(pid, subpath(path)) == nil do
      {:error, :parent_path_does_not_exist}
    else
      Agent.update(pid, &put_in(&1, path, value))
    end
  end

  def reset(pid) do
    Agent.update(pid, fn _ -> @initialstate end)
  end

  def dumpstate(pid) do
    Agent.get(pid, fn x -> x end)
  end

  defp subpath(path) do
    path -- [List.last(path)]
  end
end
