defmodule Ruler.InterpreterTest do
  use ExUnit.Case
  doctest Ruler.Interpreter



  def check(expr, out) do
    assert apply(Ruler.Interpreter, :reduce, expr) == out
  end

  test "greets the world" do
    check(["+", 1, 2], 3)
    check(["-", 5, 4], 1)
    check(["/", 5.0, 2], 2.5)
    check(["*", 6, 2], 12)
  end
end

# Ruler.Interpreter.reduce("+", 1, 6)
