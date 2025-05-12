defmodule RiotClient.HttpQueue.BackoffLimiter do
  use GenServer

  @default_backoff 10_000  # 10 seconds
  @name __MODULE__

  def start_link(_opts), do: GenServer.start_link(__MODULE__, nil, name: @name)

  def allow? do
    GenServer.call(@name, :allow?)
  end

  def notify_429(retry_after \\ nil) do
    GenServer.cast(@name, {:rate_limited, retry_after})
  end

  def backoff_ms do
    GenServer.call(@name, :backoff_ms)
  end

  # Internal State
  def init(_) do
    {:ok, %{backoff_until: nil}}
  end

  def handle_call(:allow?, _from, %{backoff_until: nil} = state) do
    {:reply, true, state}
  end

  def handle_call(:allow?, _from, %{backoff_until: ts} = state) do
    now = now()
    if now >= ts do
      {:reply, true, %{state | backoff_until: nil}}
    else
      {:reply, false, state}
    end
  end

  def handle_call(:backoff_ms, _from, %{backoff_until: backoff_until} = state) do
    backoff_ms = trunc((backoff_until - now()))
    {:reply, backoff_ms, state}
  end

  def handle_cast({:rate_limited, retry_after}, state) do
    backoff_duration =
      case retry_after do
        n when is_integer(n) -> n * 1_000
        n when is_binary(n) -> parse_retry_after(n)
        _ -> @default_backoff
      end

    new_ts = now() + backoff_duration
    {:noreply, %{state | backoff_until: new_ts}}
  end

  defp now, do: System.system_time(:millisecond)

  defp parse_retry_after(str) do
    case Integer.parse(str) do
      {n, _} -> n * 1_000
      _ -> @default_backoff
    end
  end
end
