defmodule LearnElixirFinal.PuuidPipeline.LeagueAccountProducer do
  use GenStage
  alias LearnElixirFinal.Leagues

  @league_account_polling_time 1

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, 0, name: __MODULE__)
  end

  def init(_opts) do
    schedule_refresh()
    {:producer, 0}
  end

  def handle_info(:refresh, pending) do
    schedule_refresh()
    dispatch_events(pending)
  end

  def handle_demand(demand, pending) do
    dispatch_events(demand + pending)
  end

  defp dispatch_events(demand) do
    # start_time = System.system_time()
    league_accounts = Leagues.all_league_accounts(%{
      last: demand,
      puuid: %{==: nil},
      order_by: {:asc, :updated_at}
    })
    |> Enum.filter(&(is_current_node_responsible(&1)))
    size = length(league_accounts)
    {:noreply, league_accounts, demand - size}
    # case Accounts.get_users_for_token_update(demand) do
    #   {:ok, {size, events}} ->
    #     events = Enum.map(events, &(Map.put(&1, :start_time, start_time)))
    #     {:noreply, events, demand - size}
    #   _ ->
    #     {:noreply, [], demand}
    # end
  end

  defp schedule_refresh do
    Process.send_after(self(), :refresh, @league_account_polling_time * 1000)
  end

  def is_current_node_responsible(league_account) do
    Node.self() === responsible_node(league_account.id)
  end

  def responsible_node(user_id) do
    nodes = [Node.self | Node.list]
    num_partitions = length(nodes)
    partition = :erlang.phash2(user_id, num_partitions)
    Enum.at(nodes, partition)
  end
end
