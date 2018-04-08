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
    res = Ruler.InterpreterList.reduce(ctx, a)
    assert res == 28.109999999999985
  end
end
