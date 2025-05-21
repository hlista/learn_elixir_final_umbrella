defmodule LearnElixirFinalWeb.Subscription.Tracker do
  use Agent
  @table :active_subscription_topics

  def start_link(_opts) do
    :ets.new(@table, [:named_table, :public, :set])
    {:ok, self()}
  end

  def track(topic), do: :ets.insert(@table, {topic, true})
  def untrack(topic), do: :ets.delete(@table, topic)

  def list_topics do
    :ets.tab2list(@table)
    |> Enum.map(fn {topic, _} -> topic end)
  end
end
