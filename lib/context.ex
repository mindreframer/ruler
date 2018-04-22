defmodule Ruler.Context do
  def get(ctx, path) when is_map(ctx) do
    if path_exists?(ctx, path) do
      {:ok, get_in(ctx, path), ctx}
    else
      {:error, {:path_does_not_exist, path}, ctx}
    end
  end

  @doc """
  Puts the `value` for the given `key`.
  """
  def set(ctx, path, value) when is_map(ctx) do
    if length(path) > 1 and get(ctx, subpath(path)) == nil do
      {:error, :parent_path_does_not_exist}
    else
      {:ok, true, put_in(ctx, path, value)}
    end
  end

  @doc """
  checks whether full path exists in a Map
  """
  def path_exists?(map, [head | []]) do
    Map.has_key?(map, head)
  end
  def path_exists?(map, [head | tail]) do
    Map.has_key?(map, head) and path_exists?(Map.get(map, head), tail)
  end

  defp subpath(path) when is_list(path) do
    path -- [List.last(path)]
  end
end
