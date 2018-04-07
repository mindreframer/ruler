defmodule Ruler.InterpreterList do
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

  def reduce(ctx, ["." | path]) do
    Ruler.Context.get(ctx, path)
  end

  def reduce(_ctx, expr) when is_number(expr) do
    expr
  end
end

defmodule Ruler.Context do
  def get(ctx, path) do
    get_in(ctx, path)
  end
end
