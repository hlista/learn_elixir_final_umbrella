defmodule LearnElixirFinalWeb.Subscription.EventDispatcher do
  use GenServer
  alias LearnElixirFinalWeb.LearnElixirFinalProxy
  alias LearnElixirFinalWeb.Subscription.Tracker
  @interval :timer.seconds(30)

  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def init(_) do
    schedule_dispatch()
    {:ok, %{}}
  end

  def handle_info(:dispatch, state) do
    dispatch_oban_jobs()
    schedule_dispatch()
    {:noreply, state}
  end

  defp schedule_dispatch do
    Process.send_after(self(), :dispatch, @interval)
  end

  defp dispatch_oban_jobs do
    for topic <- Tracker.list_topics() do
      case topic do
        "league_account_match_added:puuid:" <> puuid ->
          LearnElixirFinalProxy.queue_league_account_puuid_match_listening_event(%{puuid: puuid})
        "league_account_match_added:league_account_id:" <> league_account_id ->
          LearnElixirFinalProxy.queue_league_account_id_match_listening_event(%{league_account_id: league_account_id})
        "user_match_added:" <> user_id ->
          LearnElixirFinalProxy.queue_user_match_listening_event(user_id)
        _ ->
          :ok
      end
    end
  end
end
