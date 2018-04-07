defmodule Ruler.InterpreterListTest do
  use ExUnit.Case
  doctest Ruler.InterpreterList

  def check(expr, out) when is_list(expr) do
    assert Ruler.InterpreterList.reduce(%{}, expr) == out
  end

  def check(ctx, expr, out) when is_list(expr) do
    assert Ruler.InterpreterList.reduce(ctx, expr) == out
  end

  test "works with basic math" do
    check(["+", 1, 2], 3)
    check(["-", 5, 4], 1)
    check(["/", 5.0, 2], 2.5)
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
    check(["and", [">", 5, 4], true], true)
    check(["and", [">", 5, 4], false], false)
  end

  test "works with data in context" do
    ctx = %{"a" => %{"b" => 5}}
    check(ctx, ["-", [".", "a", "b"], 4], 1)
    check(ctx, ["-", [".|", 6, "a", "c"], 4], 2)
  end
end
