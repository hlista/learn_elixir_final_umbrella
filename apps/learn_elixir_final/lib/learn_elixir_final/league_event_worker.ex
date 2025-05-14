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
    with {:ok, league_account} <- LeagueAccountDiscoveredEvent.create_league_account_by_puuid(puuid) do
      match_region = league_account.match_region
      %{
        league_account_id: league_account.id,
        event: @league_account_added_event,
        region: match_region
      }
      |> Oban.Job.new(queue: get_region_queue(match_region), worker: __MODULE__)
      |> Oban.insert()
    end
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{
    "event" => @league_account_discovered_event,
    "game_name" => game_name,
    "tag_line" => tag_line
  }}) do
    with {:ok, league_account} <- LeagueAccountDiscoveredEvent.create_league_account_by_game_name_tag_line(game_name, tag_line) do
      match_region = league_account.match_region
      %{
        league_account_id: league_account.id,
        event: @league_account_added_event,
        region: match_region
      }
      |> Oban.Job.new(queue: get_region_queue(match_region), worker: __MODULE__)
      |> Oban.insert()
    end
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{
    "event" => @league_account_added_event,
    "league_account_id" => league_account_id,
    "region" => region
  }}) do
    with {:ok, matches} <- LeagueAccountAddedEvent.create_players_matches(league_account_id) do
      matches
      |> Enum.map(fn match ->
        Oban.Job.new(%{
          league_match_id: match.id,
          event: @league_match_added_event,
          region: region
        }, queue: get_region_queue(region), worker: __MODULE__)
      end)
      |> Oban.insert_all()
      |> then(& {:ok, &1})
    end
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{
    "event" => @league_match_added_event,
    "league_match_id" => league_match_id,
    "region" => region
  }}) do
    with {:ok, %{
      league_match: league_match
    }} <- LeagueMatchAddedEvent.populate_match_info(league_match_id) do
      league_match.participants
      |> Enum.map(fn puuid ->
        Oban.Job.new(%{
          puuid: puuid,
          event: @league_account_discovered_event
        }, queue: get_region_queue(region), worker: __MODULE__)
      end)
      |> Oban.insert_all()
      |> then(& {:ok, &1})
    end
  end

  defp get_region_queue(region) do
    case region do
      "americas" -> :league_events_americas
      "europe" -> :league_events_europe
      "asia" -> :league_events_asia
      "sea" -> :league_events_sea
      _ -> :league_events
    end
  end
end
