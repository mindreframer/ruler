defmodule Ruler.InterpreterList do

  ## math
  def reduce(ctx, ["+", op1, op2]) do
    reduce(ctx, op1) + reduce(ctx, op2)
  end

  def reduce(ctx, ["-", op1, op2]) do
    reduce(ctx, op1) - reduce(ctx, op2)
  end

  def reduce(ctx, ["/", op1, op2]) do
    reduce(ctx, op1) / reduce(ctx, op2)
  end

  def reduce(ctx, ["*", op1, op2]) do
    reduce(ctx, op1) * reduce(ctx, op2)
  end

  ## comparisons
  def reduce(ctx, [">", op1, op2]) do
    reduce(ctx, op1) > reduce(ctx, op2)
  end

  def reduce(ctx, ["<", op1, op2]) do
    reduce(ctx, op1) < reduce(ctx, op2)
  end

  def reduce(ctx, ["<=", op1, op2]) do
    reduce(ctx, op1) <= reduce(ctx, op2)
  end

  def reduce(ctx, [">=", op1, op2]) do
    reduce(ctx, op1) >= reduce(ctx, op2)
  end

  def reduce(ctx, ["==", op1, op2]) do
    reduce(ctx, op1) == reduce(ctx, op2)
  end

  ## logic
  def reduce(ctx, ["and" | conditions]) do
    Enum.all?(conditions, fn(x)-> reduce(ctx, x) == true end)
  end

  def reduce(ctx, ["or" | conditions]) do
    Enum.any?(conditions, fn(x)-> reduce(ctx, x) == true end)
  end

  # read from context
  def reduce(ctx, ["." | path]) do
    Ruler.Context.get(ctx, path)
  end

  # read from context, fallback to default
  def reduce(ctx, [".|" | [default_value | path]]) do
    res = Ruler.Context.get(ctx, path)
    case res do
      nil -> default_value
      _ -> res
    end
  end

  def reduce(ctx, ["set" | path_with_val]) do
    val = List.last(path_with_val)
    path = path_with_val -- [val]
    Ruler.Context.set(ctx, path, val)
  end

  def reduce(_ctx, expr) when is_number(expr) do
    expr
  end
  def reduce(_ctx, expr) when is_boolean(expr) do
    expr
  end
  def reduce(_ctx, expr) when is_binary(expr) do
    expr
  end
end

defmodule Ruler.Context do
  def get(ctx, path) when is_map(ctx) do
    get_in(ctx, path)
  end

  def get(ctx, path) when is_pid(ctx) do
    Ruler.KVAgent.get(ctx, path)
  end

  def set(ctx, path, val) when is_map(ctx) do
    put_in(ctx, path, val)
  end

  def set(ctx, path, val) when is_pid(ctx) do
    Ruler.KVAgent.set(ctx, path, val)
  end
end



defmodule Ruler.KVAgent do
  # https://elixir-lang.org/getting-started/mix-otp/agent.html
  use Agent

  @doc """
  Starts a new KVAgent.
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
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
    Agent.update(pid, &put_in(&1, path, value))
  end

  def reset(pid) do
    Agent.update(pid, fn(_) -> %{} end)
  end
end
