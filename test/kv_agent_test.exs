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

  test "nested paths require existence" do
    {:ok, ctx} = Ruler.KVAgent.start_link([])
    assert Ruler.KVAgent.get(ctx, ["a", "b"]) == nil
    assert Ruler.KVAgent.get(ctx, ["a", "b", "c"]) == nil
    assert Ruler.KVAgent.set(ctx, ["a", "b"], 1) == {:error, :parent_path_does_not_exist}
    assert Ruler.KVAgent.get(ctx, ["a", "b"]) == nil
    assert Ruler.KVAgent.set(ctx, ["a"], %{}) == :ok
    assert Ruler.KVAgent.set(ctx, ["a", "b"], 1) == :ok
    assert Ruler.KVAgent.get(ctx, ["a", "b"]) == 1
  end
end
