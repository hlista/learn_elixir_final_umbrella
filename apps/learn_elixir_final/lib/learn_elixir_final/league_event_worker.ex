defmodule LearnElixirFinal.LeagueEventWorker do
  use Oban.Worker,
  queue: :league_events,
  max_attempts: 10,
  unique: [period: 300, states: [:available, :scheduled, :executing]]

  alias LearnElixirFinal.LeagueEventWorker.{
    UserMatchListeningEvent,
    LeagueAccountMatchListeningEvent,
    LeagueMatchFoundEvent,
    LeagueMatchParticipantFoundEvent
  }
  alias LearnElixirFinal.LeagueAccount

  @league_match_found_event "league_match_found_event"
  @league_match_participant_found_event "league_match_participant_found_event"
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
    "puuid" => puuid
  }}) do
    with {:ok, league_account} <- LeagueAccount.find_or_create_league_account(puuid),
    {:ok, match_ids} <- LeagueAccountMatchListeningEvent.find_league_account_matches(league_account) do
      bulk_queue_league_match_found_event(match_ids, league_account.region)
    end
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{
    "event" => @league_match_found_event,
    "league_match_id" => league_match_id,
    "region" => region
  }}) do
    with {:ok, %{
      match_participants_info: match_participants_info
    }} <- LeagueMatchFoundEvent.maybe_create_league_match(league_match_id, region) do
      bulk_queue_league_match_participant_found_event(match_participants_info, region)
    end
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{
    "event" => @league_match_participant_found_event,
    "participant" => league_match_participant_info
  }}) do
    with {:ok, _} <- LeagueAccount.find_or_create_league_account(league_match_participant_info.puuid),
    {:ok, %{
      league_match_participant: league_match_participant
    }} <- LeagueMatchParticipantFoundEvent.maybe_create_league_match_participant(league_match_participant_info) do

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
        event: @league_account_match_listening_event
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

  def bulk_queue_league_match_found_event(match_ids, region) do
    match_ids
    |> Enum.map(fn match_id ->
      Oban.Job.new(%{
        league_match_id: match_id,
        region: region,
        event: @league_match_found_event
      }, queue: get_region_queue(region), worker: __MODULE__)
    end)
    |> Oban.insert_all()
  end

  def bulk_queue_league_match_participant_found_event(participants_info, region) do
    participants_info
    |> Enum.map(fn participant_info ->
      Oban.Job.new(%{
        participant: participant_info,
        region: region,
        event: @league_match_participant_found_event
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
