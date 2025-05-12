defmodule RiotClient.HttpQueue do
  use GenServer
  alias RiotClient.HttpQueue.HttpQueueWorker

  @queue_limit 100
  @concurrency 5

  def start_link(_), do: GenServer.start_link(__MODULE__, %{queue: :queue.new(), active: 0}, name: __MODULE__)

  def enqueue_request(%{method: _, url: _, headers: _, body: _, opts: _, client: _} = req) do
    req = Map.put(req, :retries, 0)
    GenServer.cast(__MODULE__, {:enqueue, req, self()})
    receive do
      {:http_response, result} -> result
    after
      10_000 -> {:error, :timeout}
    end
  end

  def init(state), do: {:ok, state}

  def handle_cast({:enqueue, req, from_pid}, %{queue: _q, active: n} = state) when n < @concurrency do
    spawn_worker(req, from_pid)
    {:noreply, %{state | active: n + 1}}
  end

  def handle_cast({:enqueue, req, from_pid}, %{queue: q, active: n} = state) do
    if :queue.len(q) >= @queue_limit do
      send(from_pid, {:http_response, {:error, :queue_full}})
      {:noreply, state}
    else
      {:noreply, %{state | queue: :queue.in({req, from_pid}, q)}}
    end
  end

  def handle_info({:worker_done}, %{queue: q, active: n} = state) do
    case :queue.out(q) do
      {{:value, {url, from_pid}}, q2} ->
        spawn_worker(url, from_pid)
        {:noreply, %{state | queue: q2}}

      {:empty, _} ->
        {:noreply, %{state | active: n - 1}}
    end
  end

  defp spawn_worker(req, from_pid) do
    Task.start(fn ->
      HttpQueueWorker.run(req, from_pid)
      send(__MODULE__, {:worker_done})
    end)
  end
end
