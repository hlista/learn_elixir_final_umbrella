defmodule LearnElixirFinal.LeagueEventWorkerTest do
  use LearnElixirFinalPg.DataCase
  use Oban.Testing, repo: LearnElixirFinalPg.Repo
  import LearnElixirFinalPg.Factory

  alias LearnElixirFinal.LeagueEventWorker

  describe "@queue_user_match_listening_event/1" do
    test "queue event assert" do
      LeagueEventWorker.queue_user_match_listening_event(5)
      assert_enqueued worker: LeagueEventWorker, args: %{user_id: 5, event: "user_match_listening_event"}
    end

    test "queue uniqueness"  do
      LeagueEventWorker.queue_user_match_listening_event(5)
      LeagueEventWorker.queue_user_match_listening_event(5)
      jobs = all_enqueued(worker: LeagueEventWorker)
      assert 1 == length(jobs)
    end

    test "queue not unique" do
      LeagueEventWorker.queue_user_match_listening_event(5)
      LeagueEventWorker.queue_user_match_listening_event(6)
      jobs = all_enqueued(worker: LeagueEventWorker)
      assert 2 == length(jobs)
    end
  end

  describe "@queue_league_account_match_listening_event/1" do
    test "queue event assert" do
      LeagueEventWorker.queue_league_account_match_listening_event(%{puuid: "foo"})
      assert_enqueued worker: LeagueEventWorker, args: %{params: %{puuid: "foo"}, event: "league_account_match_listening_event"}
    end

    test "queue uniqueness" do
      LeagueEventWorker.queue_league_account_match_listening_event(%{puuid: "foo"})
      LeagueEventWorker.queue_league_account_match_listening_event(%{puuid: "foo"})
      jobs = all_enqueued(worker: LeagueEventWorker)
      assert 1 == length(jobs)
    end

    test "queue not unique" do
      LeagueEventWorker.queue_league_account_match_listening_event(%{puuid: "abc"})
      LeagueEventWorker.queue_league_account_match_listening_event(%{puuid: "efg"})
      jobs = all_enqueued(worker: LeagueEventWorker)
      assert 2 == length(jobs)
    end
  end

  describe "@bulk_queue_league_account_match_listening_event/1" do
    test "queue event assert" do
      league_accounts = [
        %{id: 1, match_region: "americas"},
        %{id: 2, match_region: "europe"},
        %{id: 3, match_region: "sea"},
        %{id: 4, match_region: "asia"}
      ]
      LeagueEventWorker.bulk_queue_league_account_match_listening_event(league_accounts)
      assert_enqueued(
        worker: LeagueEventWorker,
        args: %{params: %{league_account_id: 1}, event: "league_account_match_listening_event"},
        queue: :league_events_americas
      )
      assert_enqueued(
        worker: LeagueEventWorker,
        args: %{params: %{league_account_id: 2}, event: "league_account_match_listening_event"},
        queue: :league_events_europe
      )
      assert_enqueued(
        worker: LeagueEventWorker,
        args: %{params: %{league_account_id: 3}, event: "league_account_match_listening_event"},
        queue: :league_events_sea
      )
      assert_enqueued(
        worker: LeagueEventWorker,
        args: %{params: %{league_account_id: 4}, event: "league_account_match_listening_event"},
        queue: :league_events_asia
      )
    end

    test "queue uniqueness" do
      league_accounts = [
        %{id: 1, match_region: "americas"},
        %{id: 1, match_region: "europe"},
      ]
      LeagueEventWorker.bulk_queue_league_account_match_listening_event(league_accounts)
      jobs = all_enqueued(worker: LeagueEventWorker)
      assert 1 == length(jobs)
    end
  end

  describe "@bulk_queue_league_match_found_event/2" do
    test "queue event assert" do
      match_ids = ["match_1", "match_2", "match_3"]
      LeagueEventWorker.bulk_queue_league_match_found_event(match_ids, "americas")
      assert_enqueued worker: LeagueEventWorker, args: %{league_match_id: "match_1", event: "league_match_found_event"}
      assert_enqueued worker: LeagueEventWorker, args: %{league_match_id: "match_2", event: "league_match_found_event"}
      assert_enqueued worker: LeagueEventWorker, args: %{league_match_id: "match_3", event: "league_match_found_event"}
    end

    test "queue uniqueness" do
      match_ids = ["match_1", "match_1"]
      LeagueEventWorker.bulk_queue_league_match_found_event(match_ids, "americas")
      jobs = all_enqueued(worker: LeagueEventWorker)
      assert 1 == length(jobs)
    end
  end

  describe "@bulk_queue_league_match_participant_found_event/2" do
    test "queue event assert" do
      match_participant = :match_participant
      |> build()
      |> Map.from_struct()
      |> Map.take(LearnElixirFinalPg.League.MatchParticipant.__schema__(:fields))
      |> Map.drop([:inserted_at, :updated_at, :id])
      match_participants = [match_participant]
      LeagueEventWorker.bulk_queue_league_match_participant_found_event(match_participants, "americas")
      assert_enqueued worker: LeagueEventWorker, args: %{participant: match_participant, event: "league_match_participant_found_event"}
    end

    test "queue uniqueness" do
      match_participant = :match_participant
      |> build()
      |> Map.from_struct()
      |> Map.take(LearnElixirFinalPg.League.MatchParticipant.__schema__(:fields))
      |> Map.drop([:inserted_at, :updated_at, :id])
      match_participants = [match_participant, match_participant]
      LeagueEventWorker.bulk_queue_league_match_participant_found_event(match_participants, "americas")
      jobs = all_enqueued(worker: LeagueEventWorker)
      assert 1 == length(jobs)
    end
  end

  describe "@bulk_queue_aggregate_user_matches_event/2" do
    test "queue event assert" do
      LeagueEventWorker.bulk_queue_aggregate_user_matches_event([%{id: 2}, %{id: 3}])
      assert_enqueued(worker: LeagueEventWorker, args: %{user_id: 2, event: "aggregate_user_matches_event"}, queue: :league_events)
      assert_enqueued(worker: LeagueEventWorker, args: %{user_id: 3, event: "aggregate_user_matches_event"}, queue: :league_events)
    end

    test "queue uniqueness" do
      users = [%{id: 2}, %{id: 2}]
      LeagueEventWorker.bulk_queue_aggregate_user_matches_event(users)
      jobs = all_enqueued(worker: LeagueEventWorker)
      assert 1 == length(jobs)
    end
  end

  describe "@bulk_queue_aggregate_league_account_matches_event/2" do
    test "queue event assert" do
      LeagueEventWorker.bulk_queue_aggregate_league_account_matches_event([%{id: 2}, %{id: 3}])
      assert_enqueued(worker: LeagueEventWorker, args: %{league_account_id: 2, event: "aggregate_league_account_matches_event"}, queue: :league_events)
      assert_enqueued(worker: LeagueEventWorker, args: %{league_account_id: 3, event: "aggregate_league_account_matches_event"}, queue: :league_events)
    end

    test "queue uniqueness" do
      league_accounts = [%{id: 2}, %{id: 2}]
      LeagueEventWorker.bulk_queue_aggregate_league_account_matches_event(league_accounts)
      jobs = all_enqueued(worker: LeagueEventWorker)
      assert 1 == length(jobs)
    end
  end
end
