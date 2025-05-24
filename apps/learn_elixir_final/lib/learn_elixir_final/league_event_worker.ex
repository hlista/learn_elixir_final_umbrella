defmodule LearnElixirFinal.LeagueEventWorker do
  use Oban.Worker,
    max_attempts: 5

  alias LearnElixirFinal.LeagueEventWorker.{
    AggregateLeagueAccountMatchesEvent,
    AggregateUserMatchesEvent,
    UserMatchListeningEvent,
    LeagueAccountMatchListeningEvent,
    LeagueMatchFoundEvent,
    LeagueMatchParticipantFoundEvent,
    UniquenessConstraints
  }

  alias LearnElixirFinal.{
    LeagueAccount,
    LearnElixirFinalWebProxy
  }

  @user_match_listening_event "user_match_listening_event"
  @league_account_match_listening_event "league_account_match_listening_event"
  @league_match_found_event "league_match_found_event"
  @league_match_participant_found_event "league_match_participant_found_event"
  @aggregate_user_matches_event "aggregate_user_matches_event"
  @aggregate_league_account_matches_event "aggregate_league_account_matches_event"

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{
          "event" => @user_match_listening_event,
          "user_id" => user_id
        }
      }) do
    case UserMatchListeningEvent.find_user_league_accounts(user_id) do
      {:ok, league_accounts} ->
        bulk_queue_league_account_match_listening_event(league_accounts)
      {:error, %ErrorMessage{code: :not_found}} ->
        {:ok, "User does not exist"}
      e -> e
    end
  end

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{
          "event" => @league_account_match_listening_event,
          "params" => params
        }
      }) do
    params = %{
      id: params["league_account_id"],
      puuid: params["puuid"]
    }
    params = Map.filter(params, & elem(&1, 1))
    case LeagueAccountMatchListeningEvent.find_league_account_matches(params) do
      {:ok, %{
        match_ids: match_ids,
        league_account: league_account
      }} ->
        bulk_queue_league_match_found_event(match_ids, league_account.match_region)
      {:error, "Invalid player"} -> {:ok, "Player does not exist"}
      {:error, "Invalid region"} -> {:ok, "Region does not exist"}
      {:error, "Invalid Api Key"} -> {:ok, "Api Key expired"}
      {:error, "Invalid account params"} -> {:ok, "Invalid account params"}
      {:error, %{code: :not_found}} -> {:ok, "Player does not exist"}
      e -> e
    end
  end

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{
          "event" => @league_match_found_event,
          "league_match_id" => league_match_id,
          "region" => region
        }
      }) do
    case LeagueMatchFoundEvent.maybe_create_league_match(league_match_id, region) do
      {:ok, %{match_participants_info: match_participants_info}} ->
        bulk_queue_league_match_participant_found_event(match_participants_info, region)
      {:error, "Invalid Api Key"} ->
        {:ok, "Api Key expired"}
      {:error, "resource not found"} ->
        {:ok, "Match does not exist"}
      e -> e
    end
  end

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{
          "event" => @league_match_participant_found_event,
          "participant" => league_match_participant_info
        }
      }) do
    with {:ok, _} <-
           LeagueAccount.find_or_create_league_account(%{
             puuid: league_match_participant_info["puuid"]
           }),
         {:ok,
          %{
            users: users,
            league_accounts: league_accounts
          }} <-
           LeagueMatchParticipantFoundEvent.maybe_create_league_match_participant(
             league_match_participant_info
           ) do
      bulk_queue_aggregate_user_matches_event(users)
      bulk_queue_aggregate_league_account_matches_event(league_accounts)
      :ok
    end
  end

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{
          "event" => @aggregate_user_matches_event,
          "user_id" => user_id
        }
      }) do
    with {:ok, _} <- AggregateUserMatchesEvent.update_user_match_aggregate(user_id) do
      LearnElixirFinalWebProxy.publish(%{}, :user_match_added, "user_match_added:#{user_id}")
      :ok
    end
  end

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{
          "event" => @aggregate_league_account_matches_event,
          "league_account_id" => league_account_id
        }
      }) do
    with {:ok, _} <-
           AggregateLeagueAccountMatchesEvent.update_league_account_match_aggregate(
             league_account_id
           ) do
      LearnElixirFinalWebProxy.publish(
        %{},
        :league_account_match_added,
        "league_account_match_added:#{league_account_id}"
      )

      :ok
    end
  end

  def queue_user_match_listening_event(user_id) do
    job =
      Oban.Job.new(
        %{
          user_id: user_id,
          event: @user_match_listening_event
        },
        queue: :league_events_americas,
        worker: __MODULE__,
        unique: UniquenessConstraints.user_match_listening_event()
      )

    Oban.insert(job)
  end

  def queue_league_account_match_listening_event(params) do
    job =
      Oban.Job.new(
        %{
          params: params,
          event: @league_account_match_listening_event
        },
        queue: :league_events_americas,
        worker: __MODULE__,
        unique: UniquenessConstraints.league_account_match_listening_event()
      )

    Oban.insert(job)
  end

  def bulk_queue_league_account_match_listening_event(league_accounts) do
    Enum.each(league_accounts, fn league_account ->
      job = Oban.Job.new(
        %{
          params: %{league_account_id: league_account.id},
          event: @league_account_match_listening_event
        },
        queue: get_region_queue(league_account.match_region),
        worker: __MODULE__,
        unique: UniquenessConstraints.league_account_match_listening_event()
      )
      Oban.insert(job)
    end)
  end

  def bulk_queue_league_match_found_event(match_ids, region) do
    Enum.each(match_ids, fn match_id ->
      job = Oban.Job.new(
        %{
          league_match_id: match_id,
          region: region,
          event: @league_match_found_event
        },
        queue: get_region_queue(region),
        worker: __MODULE__,
        unique: UniquenessConstraints.league_match_found_event()
      )
      Oban.insert(job)
    end)
  end

  def bulk_queue_league_match_participant_found_event(participants_info, region) do
    Enum.each(participants_info, fn participant_info ->
      job = Oban.Job.new(
        %{
          participant: participant_info,
          region: region,
          event: @league_match_participant_found_event
        },
        queue: get_region_queue(region),
        worker: __MODULE__,
        unique: UniquenessConstraints.league_match_participant_found_event()
      )
      Oban.insert(job)
    end)
  end

  def bulk_queue_aggregate_user_matches_event(users) do
    Enum.each(users,fn user ->
      job = Oban.Job.new(
        %{
          user_id: user.id,
          event: @aggregate_user_matches_event
        },
        queue: :league_events,
        worker: __MODULE__,
        unique: UniquenessConstraints.aggregate_user_matches_event()
      )
      Oban.insert(job)
    end)
  end

  def bulk_queue_aggregate_league_account_matches_event(league_accounts) do
    Enum.each(league_accounts, fn league_account ->
      job = Oban.Job.new(
        %{
          league_account_id: league_account.id,
          event: @aggregate_league_account_matches_event
        },
        queue: :league_events,
        worker: __MODULE__,
        unique: UniquenessConstraints.aggregate_league_account_matches_event()
      )
      Oban.insert(job)
    end)
  end

  def user_match_listening_event, do: @user_match_listening_event
  def league_account_match_listening_event, do: @league_account_match_listening_event
  def league_match_found_event, do: @league_match_found_event
  def league_match_participant_found_event, do: @league_match_participant_found_event
  def aggregate_user_matches_event, do: @aggregate_user_matches_event
  def aggregate_league_account_matches_event, do: @aggregate_league_account_matches_event

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
