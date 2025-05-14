defmodule RiotClient.TokenBucketLimiter do
  use GenServer

  def start_link(opts) do
    name = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def allow?(name), do: GenServer.call(name, :allow?)

  @impl true
  def init(opts) do
    rate_limit = Keyword.get(opts, :rate_limit, 100)     # e.g., 100
    max_tokens = Keyword.get(opts, :max_tokens, rate_limit)
    interval = Keyword.get(opts, :interval, 1_000)      # default: per second
    now = now()
    state = %{
      tokens: max_tokens,
      last_refill: now,
      rate_limit: rate_limit,
      max_tokens: max_tokens,
      interval: interval
    }

    {:ok, state}
  end

  @impl true
  def handle_call(:allow?, _from, state) do
    now = now()
    elapsed_ms = now - state.last_refill

    refill_rate_per_ms = state.rate_limit / state.interval
    tokens_to_add = floor(refill_rate_per_ms * elapsed_ms)
    new_token_count = min(state.max_tokens, state.tokens + tokens_to_add)

    if new_token_count >= 1 do
      {:reply, true, %{state | tokens: new_token_count - 1, last_refill: now}}
    else
      {:reply, false, %{state | tokens: new_token_count, last_refill: now}}
    end
  end

  defp now, do: System.system_time(:millisecond)
end
