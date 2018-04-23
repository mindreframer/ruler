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

  def eval_ast(ctx, ["~", op1, op2]) do
    with {:ok, op1, ctx} <- eval_ast(ctx, op1),
         {:ok, op2, ctx} <- eval_ast(ctx, op2),
         {:ok, op2} <- Regex.compile(op2),
         do: {:ok, op1 =~ op2, ctx}
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
    Ruler.Context.get(ctx, bindings_path(ctx, path))
  end

  # read from context, fallback to default
  def eval_ast(ctx, [".|" | [default_value | path]]) do
    case res = Ruler.Context.get(ctx, bindings_path(ctx, path)) do
      {:error, _, ctx} -> {:ok, default_value, ctx}
      _ -> res
    end
  end

  # set value on context
  def eval_ast(ctx, ["set" | path_with_val]) do
    val = List.last(path_with_val)
    path = path_with_val -- [val]
    Ruler.Context.set(ctx, bindings_path(ctx, path), val)
  end

  def eval_ast(ctx, ["do" | [item_path | blk = [[[var_name], blk_expr]]]]) do
    with {:ok, item, ctx} <- eval_ast(ctx, item_path),
         {:ok, true, ctx_1} <- eval_ast(ctx, ["set", var_name, item]),
         {:ok, res, ctx_2} <- eval_ast(ctx_1, blk_expr),
         do: {:ok, res, ctx_2}
  end

  def eval_ast(ctx, ["catch" | [default_value | [expr]]]) do
    case eval_ast(ctx, expr) do
      {:ok, res, new_ctx} -> {:ok, res, new_ctx}
      _ -> {:ok, default_value, ctx}
    end
  end

  def eval_ast(ctx, ["filter" | [collection | blk = [[[var_name], blk_expr]]]]) do
    with {:ok, collection, ctx} <- eval_ast(ctx, collection),
          res <- Enum.filter(collection, fn(item)-> filter_helper(ctx, item, var_name, blk_expr) == {:ok, true} end),
          do: {:ok, res, ctx}
  end


  def eval_ast(ctx, ["filter" | [collection | _blk]]) do
    {:error, {:filter_did_not_match}, ctx}
  end

  def filter_helper(ctx, item, varname, blk_expr) do
    with {:ok, true, ctx_1} <- eval_ast(ctx, ["set", varname, item]),
         {:ok, res, ctx_2} <- eval_ast(ctx_1, blk_expr),
         do: {:ok, res}
  end

  # count

  # sum

  # "noop"

  # "foreach"

  def eval_ast(ctx, expr) when is_number(expr) do
    {:ok, Decimal.new(expr), ctx}
  end

  def eval_ast(ctx, expr)
      when is_boolean(expr)
      when is_binary(expr) do
    {:ok, expr, ctx}
  end

  # non-matching list, must be a simple list with data
  def eval_ast(ctx, expr) when is_list(expr) do
    {:ok, expr, ctx}
  end

  # TODO: make sure path contains only string by evaling more complex expressions
  defp bindings_path(_ctx, path) do
    ["bindings" | path]
  end
end
