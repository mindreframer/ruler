## https://github.com/serverboards/serverboards/blob/master/backend/apps/serverboards/lib/exeval/exeval.ex
## https://github.com/serverboards/serverboards/blob/master/backend/apps/serverboards/test/exeval_test.exs
defmodule Ruler.InterpreterList do
  use DecimalArithmetic
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
    Enum.all?(conditions, fn x -> reduce(ctx, x) == true end)
  end

  def reduce(ctx, ["or" | conditions]) do
    Enum.any?(conditions, fn x -> reduce(ctx, x) == true end)
  end

  # read from context
  def reduce(ctx, ["." | path]) do
    Ruler.Context.get(ctx, bindings_path(path))
  end

  # read from context, fallback to default
  def reduce(ctx, [".|" | [default_value | path]]) do
    res = Ruler.Context.get(ctx, bindings_path(path))

    case res do
      nil -> default_value
      _ -> res
    end
  end

  # set value on context
  def reduce(ctx, ["set" | path_with_val]) do
    val = List.last(path_with_val)
    path = path_with_val -- [val]
    Ruler.Context.set(ctx, bindings_path(path), val)
  end

  def reduce(_ctx, expr) when is_integer(expr) do
    Decimal.new(expr)
  end

  def reduce(_ctx, expr) when is_float(expr) do
    Decimal.from_float(expr)
  end

  def reduce(_ctx, expr)
      when is_boolean(expr)
      when is_binary(expr) do
    expr
  end

  defp bindings_path(path) do
    ["bindings" | path]
  end
end
