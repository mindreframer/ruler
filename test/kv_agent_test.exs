defmodule Ruler.KVAgentTest do
  use ExUnit.Case
  # doctest Ruler.InterpreterList

  test "basic operations on Ruler.KVAgent" do
    {:ok, ctx} = Ruler.KVAgent.start_link([])
    assert Ruler.KVAgent.get(ctx, ["a"]) == nil
    Ruler.KVAgent.set(ctx, ["a"], 1)
    assert Ruler.KVAgent.get(ctx, ["a"]) == 1
    Ruler.KVAgent.reset(ctx)
    assert Ruler.KVAgent.get(ctx, ["a"]) == nil
  end
end
