## https://github.com/serverboards/serverboards/blob/master/backend/apps/serverboards/lib/exeval/exeval.ex
## https://github.com/serverboards/serverboards/blob/master/backend/apps/serverboards/test/exeval_test.exs
defmodule Ruler.InterpreterStateless do
  use DecimalArithmetic
  ## math
  def eval_ast(ctx, ["+", op1, op2]) do
    with {:ok, op1, ctx} <- eval_ast(ctx, op1),
         {:ok, op2, ctx} <- eval_ast(ctx, op2),
         do: {:ok, op1 + op2, ctx}
  end

  def eval_ast(ctx, ["-", op1, op2]) do
    with {:ok, op1, ctx} <- eval_ast(ctx, op1),
         {:ok, op2, ctx} <- eval_ast(ctx, op2),
         do: {:ok, op1 - op2, ctx}
  end

  def eval_ast(ctx, ["/", op1, op2]) do
    with {:ok, op1, ctx} <- eval_ast(ctx, op1),
         {:ok, op2, ctx} <- eval_ast(ctx, op2),
         do: {:ok, op1 / op2, ctx}
  end

  def eval_ast(ctx, ["*", op1, op2]) do
    with {:ok, op1, ctx} <- eval_ast(ctx, op1),
         {:ok, op2, ctx} <- eval_ast(ctx, op2),
         do: {:ok, op1 * op2, ctx}
  end

  ## comparisons
  def eval_ast(ctx, [">", op1, op2]) do
    with {:ok, op1, ctx} <- eval_ast(ctx, op1),
         {:ok, op2, ctx} <- eval_ast(ctx, op2),
         do: {:ok, op1 > op2, ctx}
  end

  def eval_ast(ctx, ["<", op1, op2]) do
    with {:ok, op1, ctx} <- eval_ast(ctx, op1),
         {:ok, op2, ctx} <- eval_ast(ctx, op2),
         do: {:ok, op1 < op2, ctx}
  end

  def eval_ast(ctx, ["<=", op1, op2]) do
    with {:ok, op1, ctx} <- eval_ast(ctx, op1),
         {:ok, op2, ctx} <- eval_ast(ctx, op2),
         do: {:ok, op1 <= op2, ctx}
  end

  def eval_ast(ctx, [">=", op1, op2]) do
    with {:ok, op1, ctx} <- eval_ast(ctx, op1),
         {:ok, op2, ctx} <- eval_ast(ctx, op2),
         do: {:ok, op1 >= op2, ctx}
  end

  def eval_ast(ctx, ["==", op1, op2]) do
    with {:ok, op1, ctx} <- eval_ast(ctx, op1),
         {:ok, op2, ctx} <- eval_ast(ctx, op2),
         do: {:ok, op1 == op2, ctx}
  end

  ## logic
  def eval_ast(ctx, ["and" | conditions]) do
    {:ok, Enum.all?(conditions, fn x -> eval_ast(ctx, x) == {:ok, true, ctx} end), ctx}
  end

  def eval_ast(ctx, ["or" | conditions]) do
    {:ok, Enum.any?(conditions, fn x -> eval_ast(ctx, x) == {:ok, true, ctx} end), ctx}
  end

  # read from context
  def eval_ast(ctx, ["." | path]) do
    Ruler.Context.get(ctx, bindings_path(path))
  end

  # read from context, fallback to default
  def eval_ast(ctx, [".|" | [default_value | path]]) do
    case res = Ruler.Context.get(ctx, bindings_path(path)) do
      {:error, _, ctx} -> {:ok, default_value, ctx}
      _ -> res
    end
  end

  # set value on context
  def eval_ast(ctx, ["set" | path_with_val]) do
    val = List.last(path_with_val)
    path = path_with_val -- [val]
    Ruler.Context.set(ctx, bindings_path(path), val)
  end

  def eval_ast(ctx, expr) when is_number(expr) do
    {:ok, Decimal.new(expr), ctx}
  end

  def eval_ast(ctx, expr)
      when is_boolean(expr)
      when is_binary(expr) do
    {:ok, expr, ctx}
  end

  defp bindings_path(path) do
    ["bindings" | path]
  end
end
