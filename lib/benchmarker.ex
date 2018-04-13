defmodule Ruler.Benchmarker do
  def basic_ops do
    Benchee.run(%{
      "plain"    => fn -> Ruler.InterpreterList.reduce(%{}, ["+", ["-", 5, 4], 2]) end,
      "from env" => fn -> Ruler.InterpreterList.reduce(%{"a" => %{"b" => 5}}, ["+", ["-", [".", "a", "b"], 4], 2]) end,
    },  time: 5, formatter_options: %{console: %{extended_statistics: true}})

  end

  def genserver_vs_ets do
    RetrieveState.Benchmark.benchmark()
  end
end


defmodule RetrieveState.Fast do
  def get_state(ets_pid) do
    :ets.lookup(ets_pid, :stored_state)
  end
end

defmodule StateHolder do
  use GenServer

  def init(_), do: {:ok, %{stored_state: :returned_state}}

  def start_link(state \\ []), do: GenServer.start_link(__MODULE__, state, name: __MODULE__)

  def get_state(key), do: GenServer.call(__MODULE__, {:get_state, key})

  def handle_call({:get_state, key}, _from, state), do: {:reply, state[key], state}
end


defmodule StateHolderAgent do
  use Agent
  def start_link(_opts), do: Agent.start_link(fn ->  %{stored_state: :returned_state} end)
  def get_state(pid, key), do: Agent.get(pid, &get_in(&1, key))
end

defmodule RetrieveState.Slow do
  def get_state do
    StateHolder.get_state(:stored_state)
  end
end

defmodule RetrieveState.Benchmark do
  def benchmark do
    ets_pid = :ets.new(:state_store, [:set, :public])
    :ets.insert(ets_pid, {:stored_state, :returned_state})
    StateHolder.start_link()
    {:ok, agentpid} = StateHolderAgent.start_link([])

    Benchee.run(
      %{
        "ets table" => fn -> RetrieveState.Fast.get_state(ets_pid) end,
        "gen server" => fn -> RetrieveState.Slow.get_state() end,
        "agent server" => fn -> StateHolderAgent.get_state(agentpid, [:stored_state]) end
      },
      time: 5,
      print: [fast_warning: false]
    )
  end
end
