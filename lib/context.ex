defmodule Ruler.Context do
  def get(ctx, path) when is_map(ctx) do
    get_in(ctx, path)
  end

  def get(ctx, path) when is_pid(ctx) do
    Ruler.KVAgent.get(ctx, path)
  end

  def set(ctx, path, val) when is_map(ctx) do
    put_in(ctx, path, val)
  end

  def set(ctx, path, val) when is_pid(ctx) do
    Ruler.KVAgent.set(ctx, path, val)
  end
end
