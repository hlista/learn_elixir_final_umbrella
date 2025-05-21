defmodule LearnElixirFinal.LeagueEventWorker do
  use Oban.Worker,
  queue: :league_events,
  max_attempts: 10,
  unique: [period: 300, states: [:available, :scheduled, :executing]]

  alias LearnElixirFinal.LeagueEventWorker.{
    UserMatchListeningEvent,
    LeagueAccountMatchListeningEvent,
    LeagueMatchAddedEvent
  }

  @league_match_added_event "league_match_added_event"
  @user_match_listening_event "user_match_listening_event"
  @league_account_match_listening_event "league_account_match_listening_event"

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{
    "event" => @user_match_listening_event,
    "user_id" => user_id
  }}) do
    with {:ok, league_accounts} <- UserMatchListeningEvent.find_user_league_accounts(user_id) do
      bulk_queue_league_account_match_listening_event(league_accounts)
    end
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{
    "event" => @league_account_match_listening_event,
    "puuid" => puuid,
    "region" => region
  }}) do
    with {:ok, match_ids} <- LeagueAccountMatchListeningEvent.find_league_account_matches(puuid, region) do
      bulk_queue_league_match_added_event(match_ids, region)
    end
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{
    "event" => @league_account_match_listening_event,
    "puuid" => puuid
  }}) do
    with {:ok, league_account} <- LeagueAccountMatchListeningEvent.find_and_create_league_account(puuid),
    {:ok, match_ids} <- LeagueAccountMatchListeningEvent.find_league_account_matches(puuid, league_account.region) do
      bulk_queue_league_match_added_event(match_ids, league_account.region)
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
    }} <- LeagueMatchAddedEvent.create_league_match(league_match_id, region) do
      LearnElixirFinal.PubSub.MatchAdded.notify_match_added(league_match.id)
    end
  end

  def queue_user_match_listening_event(user_id) do
    job = Oban.Job.new(%{
      user_id: user_id,
      event: @user_match_listening_event
    }, queue: :league_events_americas, worker: __MODULE__)
    Oban.insert(job)
  end

  def bulk_queue_league_account_match_listening_event(league_accounts) do
    league_accounts
    |> Enum.map(fn league_account ->
      Oban.Job.new(%{
        puuid: league_account.puuid,
        event: @league_account_match_listening_event,
        region: league_account.region
      }, queue: get_region_queue(league_account.region), worker: __MODULE__)
    end)
    |> Oban.insert_all()
  end

  def queue_league_account_match_listening_event(puuid) do
    job = Oban.Job.new(%{
      puuid: puuid,
      event: @league_account_match_listening_event,
    }, queue: :league_events_americas, worker: __MODULE__)
    Oban.insert(job)
  end

  def bulk_queue_league_match_added_event(match_ids, region) do
    match_ids
    |> Enum.map(fn match_id ->
      Oban.Job.new(%{
        league_match_id: match_id,
        region: region,
        event: @league_match_added_event
      }, queue: get_region_queue(region), worker: __MODULE__)
    end)
    |> Oban.insert_all()
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
