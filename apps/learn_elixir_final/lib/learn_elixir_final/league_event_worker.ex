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
      %{
        league_account_id: league_account.id,
        event: @league_account_added_event
      }
      |> __MODULE__.new()
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
      %{
        league_account_id: league_account.id,
        event: @league_account_added_event
      }
      |> __MODULE__.new()
      |> Oban.insert()
    end
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{
    "event" => @league_account_added_event,
    "league_account_id" => league_account_id
  }}) do
    with {:ok, matches} <- LeagueAccountAddedEvent.create_players_matches(league_account_id) do
      matches
      |> Enum.map(fn match ->
        __MODULE__.new(%{
          league_match_id: match.id,
          event: @league_match_added_event
        })
      end)
      |> Oban.insert_all()
    end
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{
    "event" => @league_match_added_event,
    "league_match_id" => league_match_id
  }}) do
    with {:ok, %{
      league_match: league_match
    }} <- LeagueMatchAddedEvent.populate_match_info(league_match_id) do
      league_match.participants
      |> Enum.map(fn puuid ->
        __MODULE__.new(%{
          puuid: puuid,
          event: @league_account_discovered_event
        })
      end)
      |> Oban.insert_all()
    end
  end
end
