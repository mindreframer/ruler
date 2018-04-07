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
    check(["and", true, true], true)
    check(["and", true, false], false)
    check(["and", false, false], false)

    check(["or", true, false], true)
    check(["or", false, true], true)
    check(["or", false, false], false)

    check(["or", [">", 2, 1], false], true)
  end

  test "works with data in context" do
    ctx = %{"a" => %{"b" => 5}, "d"=> 1}
    check(ctx, ["-", [".", "a", "b"], 4], 1)
    check(ctx, ["+", [".", "d"], 1], 2)
    check(ctx, ["-", [".|", 6, "a", "c"], 4], 2)
  end

  test "state in agents" do
    {:ok, ctx} = Ruler.KVAgent.start_link([])
    Ruler.InterpreterList.reduce(ctx, ["set", "a", 1])
    assert Ruler.KVAgent.get(ctx, ["a"]) == 1
    check(ctx, ["==", [".", "a"], 1], true)
    check(ctx, ["==", [".", "a"], 2], false)
    Ruler.InterpreterList.reduce(ctx, ["set", "a", 2])
    check(ctx, ["==", [".", "a"], 2], true)
  end
end
