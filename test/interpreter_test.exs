defmodule Ruler.InterpreterListTest do
  use ExUnit.Case
  doctest Ruler.InterpreterStateless
  use DecimalArithmetic # this helps asserting decimals against plain values

  def check(expr, out) when is_list(expr) do
    {:ok, res, _new_ctx} = Ruler.InterpreterStateless.eval_ast(%{}, expr)
    assert res == out
  end

  def check(ctx, expr, out) when is_list(expr) do
    {:ok, res, _new_ctx} = Ruler.InterpreterStateless.eval_ast(ctx, expr)
    assert res == out
  end

  test "works with basic math" do
    check(["+", 1, 2], 3)
    check(["-", 5, 4], 1)
    check(["/", 5, 2], 2.5)
    check(["*", 6, 2], 12)
  end

  test "works with nested formulas" do
    check(["+", ["-", 5, 4], 2], 3)
  end

  test "works with comparisons" do
    check([">", 5, 4], true)
    check([">", 4, 5], false)

    check(["<", 5, 4], false)
    check(["<", 4, 5], true)

    check(["<=", 5, 5], true)
    check(["<=", 4, 5], true)
    check(["<=", 6, 5], false)

    check([">=", 5, 5], true)
    check([">=", 5, 4], true)
    check([">=", 5, 6], false)
  end

  test "works with logic operands" do
    check(["and", true, true], true)
    check(["and", true, false], false)
    check(["and", false, false], false)

    check(["or", true, false], true)
    check(["or", false, true], true)
    check(["or", false, false], false)

    check(["or", [">", 2, 1], false], true)
  end

  test "works with data in context" do
    ctx = %{
      "bindings" => %{"a" => %{"b" => 5}, "d"=> 1}
    }
    check(ctx, [".", "a"], %{"b" => 5})
    check(ctx, [".", "d"], 1)

    check(ctx, ["-", [".", "a", "b"], 4], 1)
    check(ctx, ["+", [".", "d"], 1], 2)
    check(ctx, ["-", [".|", 6, "a", "c"], 4], 2)
  end
end
