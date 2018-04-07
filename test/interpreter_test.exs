defmodule Ruler.InterpreterTest do
  use ExUnit.Case
  doctest Ruler.Interpreter



  def check(expr, out) do
    assert apply(Ruler.Interpreter.reduce, expr) == out
  end

  test "greets the world" do
    assert Ruler.Interpreter.reduce(
             "+",
             1,
             3
           ) == 4
  end
end

# Ruler.Interpreter.reduce("+", 1, 6)
