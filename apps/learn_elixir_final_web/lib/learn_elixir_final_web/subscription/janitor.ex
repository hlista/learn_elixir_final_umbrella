defmodule LearnElixirFinalWeb.Subscription.Janitor do
  use GenServer
  alias LearnElixirFinalWeb.Subscription.{
    Tracker,
    Presence
  }
  @interval :timer.seconds(30)

  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def init(_) do
    schedule_cleanup()
    {:ok, %{}}
  end

  def handle_info(:cleanup, state) do
    clean_empty_topics()
    schedule_cleanup()
    {:noreply, state}
  end

  defp schedule_cleanup do
    Process.send_after(self(), :cleanup, @interval)
  end

  defp clean_empty_topics do
    for topic <- Tracker.list_topics() do
      case Presence.list(topic) do
        map when map_size(map) == 0 ->
          Tracker.untrack(topic)
        _ -> :ok
      end
    end
  end
end
