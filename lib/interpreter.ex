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
  def get(ctx, path) do
    get_in(ctx, path)
  end
end
