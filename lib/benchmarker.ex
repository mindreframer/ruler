defmodule Ruler.Benchmarker do
  def basic_ops do
    Benchee.run(%{
      "plain"    => fn -> Ruler.InterpreterList.reduce(%{}, ["+", ["-", 5, 4], 2]) end,
      "from env" => fn -> Ruler.InterpreterList.reduce(%{"a" => %{"b" => 5}}, ["+", ["-", [".", "a", "b"], 4], 2]) end,
    },  time: 5, formatter_options: %{console: %{extended_statistics: true}})

  end
end
