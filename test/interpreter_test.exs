defmodule Ruler.InterpreterListTest do
  use ExUnit.Case
  doctest Ruler.InterpreterStateless
  alias Ruler.InterpreterStateless
  # this helps asserting decimals against plain values
  use DecimalArithmetic

  @default_ctx  %{"bindings" => %{}}
  def eval_ast(ctx, expr) do
    Ruler.InterpreterStateless.eval_ast(ctx, expr)
  end

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

    check(["~", "one", "(^one$|^two$)"], true)
    check(["~", "two", "(^one$|^two$)"], true)
    check(["~", "twos", "(^one$|^two$)"], false)
    check(%{"bindings" => %{"x" => "one"}}, ["~", [".", "x"], "(^one$|^two$)"], true)
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
      "bindings" => %{"a" => %{"b" => 5}, "d" => 1}
    }

    check(ctx, [".", "a"], %{"b" => 5})
    check(ctx, [".", "d"], 1)

    check(ctx, ["-", [".", "a", "b"], 4], 1)
    check(ctx, ["+", [".", "d"], 1], 2)
    check(ctx, ["-", [".|", 6, "a", "c"], 4], 2)
  end

  test "setting / getting context data works" do
    ctx = %{
      "bindings" => %{"a" => %{"b" => 5}, "d" => 1}
    }

    {:ok, true, new_ctx} = eval_ast(ctx, ["set", "a", "b", 7])
    assert eval_ast(ctx, [".", "a", "b"]) |> elem(1) == 5
    assert eval_ast(new_ctx, [".", "a", "b"]) |> elem(1) == 7
  end

  test ":do" do
    ctx = %{
      "bindings" => %{"a" => %{"b" => 5}, "d" => 1}
    }

    {:ok, res, new_ctx} =
      eval_ast(ctx, [
        "do",
        [".", "a", "b"],
        [
          ["x"],
          ["==", [".", "x"], 5]
        ]
      ])

    assert res == true
    assert new_ctx == %{"bindings" => %{"a" => %{"b" => 5}, "d" => 1, "x" => 5}}

    {:ok, res, new_ctx} =
      eval_ast(ctx, [
        "do",
        # <- path in env
        [".", "a", "b"],
        # <- block
        [
          ["x"],
          ["+", [".", "x"], 10]
        ]
      ])

    assert res == 15
    assert new_ctx == %{"bindings" => %{"a" => %{"b" => 5}, "d" => 1, "x" => 5}}
  end

  test ":catch" do
    ctx = %{
      "bindings" => %{"a" => %{"b" => 5}, "d" => 1}
    }

    {:ok, res, new_ctx} =
      eval_ast(ctx, [
        "catch",
        "bam",
        [
          "do",
          [".", "a", "c"],
          [
            ["x"],
            ["==", [".", "x"], 5]
          ]
        ]
      ])

    assert res == "bam"

    {:ok, res, _new_ctx} =
      eval_ast(ctx, [
        "catch",
        "bam",
        [
          "do",
          [".", "a", "b"],
          [
            ["x"],
            ["==", [".", "x"], 5]
          ]
        ]
      ])

    assert res == true
  end


  test ":filter" do
    # assert {:ok, true} = InterpreterStateless.filter_helper(@default_ctx, 1, "x", ["<", [".", "x"], 3])
    # assert {:ok, true} = InterpreterStateless.filter_helper(@default_ctx, 2, "x", ["<", [".", "x"], 3])
    # assert {:ok, false} = InterpreterStateless.filter_helper(@default_ctx, 3, "x", ["<", [".", "x"], 3])

    expr = [
      "filter",
      [1,2,3],
      [
        ["x"],
        ["<", [".", "x"], 3]
      ]
    ]
    {:ok, res, _} = eval_ast(@default_ctx, expr)
    assert res == [1,2]

    expr = [
      "filter",
      [1,2,3],
      [
        [],
        ["<", [".", "y"], 3]
      ]
    ]
    {:error, {:filter_did_not_match}, _} = eval_ast(@default_ctx, expr)


    # this silently ignores the wrong binding name... could this be desired outcome?
    expr = [
      "filter",
      [1,2,3],
      [
        ["x"],
        ["<", [".", "y"], 3]
      ]
    ]
    {:ok, res, _} = eval_ast(@default_ctx, expr)
    assert res == []
  end


  test ":sum" do
    expr = [
      "sum",
      [1,2,3],
      [
        ["x"],
        [".", "x"]
      ]
    ]
    {:ok, res, _} = eval_ast(@default_ctx, expr)
    assert res == 6

    # 0 for error in block eval, maybe not desired
    expr = [
      "sum",
      [1,2,3],
      [
        ["x"],
        [".", "y"]
      ]
    ]
    {:ok, res, _} = eval_ast(@default_ctx, expr)
    assert res == 0
  end

  @tag focus: true
  test ":count" do
    expr = [
      "count",
      [1,2,3,4],
    ]
    {:ok, res, _} = eval_ast(@default_ctx, expr)
    assert res == 4

    expr = [
      "count",
      [".", "a"],
    ]
    {:ok, res, _} = eval_ast(%{"bindings" => %{"a" => [2,2]}}, expr)
    assert res == 2

    expr = [
      "count",
      [".", "a"],
    ]
    {:error, {:not_a_list, [".", "a"]}, %{"bindings" => %{"a" => 1}}} = eval_ast(%{"bindings" => %{"a" => 1}}, expr)
  end
end
