defmodule RiotClient.HttpQueue.BackoffLimiterTwo do
  use GenServer

  @interval_one 1_000
  @interval_one_requests 20
  @interval_two 120_000
  @interval_two_requests 100
  @name __MODULE__
  @region_bucket %{
    "americas" => 0,
    "europe" => 0,
    "asia" => 0,
    "sea" => 0
  }

  def start_link(_opts), do: GenServer.start_link(__MODULE__, nil, name: @name)

  def allow?(region) do
    GenServer.call(@name, {:allow?, region})
  end

  # Internal State
  def init(_) do
    # schedule_interval_one_refresh()
    # schedule_interval_two_refresh()
    {:ok, %{
      interval_one_region_bucket: @region_bucket,
      interval_two_region_bucket: @region_bucket
    }}
  end

  def handle_call(
    {:allow?, region},
    _from,
    %{
      interval_one_region_bucket: interval_one_region_bucket,
      interval_two_region_bucket: interval_two_region_bucket
    } = state
  ) when is_map_key(@region_bucket, region) do
    interval_one_requests_made = interval_one_region_bucket[region]
    interval_two_requests_made = interval_two_region_bucket[region]
    interval_one_requests_left = @interval_one_requests - interval_one_requests_made
    interval_two_requests_left = @interval_two_requests - interval_two_requests_made
    cond do
      interval_one_requests_left === 0 ->
        {:reply, false, state}
      interval_two_requests_left === 0 ->
        {:reply, false, state}
      true ->
        Process.send_after(self(), {:decrement_interval_one, region}, @interval_one)
        Process.send_after(self(), {:decrement_interval_two, region}, @interval_two)
        state = %{
          interval_one_region_bucket: %{interval_one_region_bucket | region => interval_one_requests_made + 1},
          interval_two_region_bucket: %{interval_two_region_bucket | region => interval_two_requests_made + 1}
        }
        {:reply, true, state}
    end
  end

  def handle_call({:allow?, _}, _, state) do
    {:reply, false, state}
  end

  def handle_info({:decrement_interval_one, region}, state) do
    state = %{
      state |
      interval_one_region_bucket: %{
        state[:interval_one_region_bucket] |
        region => max(state[:interval_one_region_bucket][region] - 1, 0)
      }
    }
    {:noreply, state}
  end

  def handle_info({:decrement_interval_two, region}, state) do
    state = %{
      state |
      interval_two_region_bucket: %{
        state[:interval_two_region_bucket] |
        region => max(state[:interval_two_region_bucket][region] - 1, 0)
      }
    }
    {:noreply, state}
  end

  # def handle_info(:refresh_interval_one, state) do
  #   schedule_interval_one_refresh()
  #   {:noreply, %{state | interval_one_region_bucket: @region_bucket}}
  # end

  # def handle_info(:refresh_interval_two, state) do
  #   schedule_interval_one_refresh()
  #   {:noreply, %{state | interval_two_region_bucket: @region_bucket}}
  # end

  # defp schedule_interval_one_refresh do
  #   Process.send_after(self(), :refresh_interval_one, @interval_one)
  # end

  # defp schedule_interval_two_refresh do
  #   Process.send_after(self(), :refresh_interval_two, @interval_two)
  # end
end
