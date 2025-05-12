defmodule LearnElixirFinal.LeagueEventWorker do
  use Oban.Worker,
  queue: :league_events,
  max_attempts: 10,
  unique: [period: 300, states: [:available, :scheduled, :executing]]

  alias LearnElixirFinal.LeagueEventWorker.{
    LeagueAccountDiscoveredEvent,
    LeagueAccountAddedEvent,
    LeagueMatchAddedEvent
  }

  @league_account_discovered_event "league_account_discovered_event"
  @league_account_added_event "league_account_added_event"
  @league_match_added_event "league_match_added_event"

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{
    "event" => @league_account_discovered_event,
    "puuid" => puuid
  }}) do
    LeagueAccountDiscoveredEvent.create_league_account_by_puuid(puuid)
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{
    "event" => @league_account_discovered_event,
    "game_name" => game_name,
    "tag_line" => tag_line
  }}) do
    LeagueAccountDiscoveredEvent.create_league_account_by_game_name_tag_line(game_name, tag_line)
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{
    "event" => @league_account_added_event,
    "puuid" => puuid,
    "region" => region
  }}) do

  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{
    "event" => @league_match_added_event,
    "match_id" => match_id,
    "region" => region
  }}) do

  end
end
