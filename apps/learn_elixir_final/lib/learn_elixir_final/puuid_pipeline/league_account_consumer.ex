defmodule LearnElixirFinal.PuuidPipeline.LeagueAccountConsumer do
  use GenStage
  alias LearnElixirFinal.RiotClient
  alias LearnElixirFinal.Leagues

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:consumer, %{}, subscribe_to: [{LearnElixirFinal.PuuidPipeline.LeagueAccountProducer, max_demand: 1000}]}
  end

  def handle_events(events, _from, state) do
    Enum.each(events, fn %{
      id: id,
      region: region,
      tag_line: tag_line,
      game_name: game_name
    } ->
      with {:ok, %{"puuid" => puuid}} <-
          RiotClient.get_account_by_riot_id(region, game_name, tag_line) do
        Leagues.update_league_account(id, %{puuid: puuid})
      end
    end)
    {:noreply, [], state}
  end

end
