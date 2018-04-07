defmodule Ruler.Interpreter do
  # def eval(ctx, expr) do

  # end

  def reduce("+", op1, op2) do
    reduce(op1) + reduce(op2)
  end

  def reduce("-", op1, op2) do
    reduce(op1) - reduce(op2)
  end

  def reduce(expr) when is_number(expr) do
    expr
  end
end



defmodule Ruler.Context do
  #
end
