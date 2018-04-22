defmodule Ruler.RealSamplesTest do
  use ExUnit.Case
  def read_fixture(file) do
    c = File.read!("test/fixtures/#{file}")
    Poison.decode!(c)
  end

  test "fixture1" do
    a = read_fixture("expression01.json")
    ctx = %{
      "bindings" => %{
        "Item" => %{
          "Attributes" => %{
            "rrp" => 70.9,
          },
          "Quantity" => 3,
          "Price" => 59
        }
      }
    }
    {:ok, res, _new_ctx} = Ruler.InterpreterStateless.eval_ast(ctx, a)
    assert res == Decimal.new(28.10999999999998)
  end
end
