defmodule LearnElixirFinal.LeagueEventWorkers.LeagueAccountMatchListeningTest do
  use LearnElixirFinalPg.DataCase
  use Oban.Testing, repo: LearnElixirFinalPg.Repo
  import LearnElixirFinalPg.Factory
  import Mox

  setup :set_mox_from_context

  alias LearnElixirFinal.LeagueEventWorkers.LeagueAccountMatchListening

  @riot_api_key Application.compile_env(:riot_client, :riot_api_key)

  describe "@queue_event/1" do
    test "queue event assert" do
      LeagueAccountMatchListening.queue_event(%{puuid: "foo"})
      assert_enqueued worker: LeagueAccountMatchListening, args: %{puuid: "foo"}
    end

    test "queue uniqueness" do
      LeagueAccountMatchListening.queue_event(%{puuid: "foo"})
      LeagueAccountMatchListening.queue_event(%{puuid: "foo"})
      jobs = all_enqueued(worker: LeagueAccountMatchListening)
      assert 1 == length(jobs)
    end

    test "queue not unique" do
      LeagueAccountMatchListening.queue_event(%{puuid: "abc"})
      LeagueAccountMatchListening.queue_event(%{puuid: "efg"})
      jobs = all_enqueued(worker: LeagueAccountMatchListening)
      assert 2 == length(jobs)
    end
  end

  describe "@bulk_queue_events/1" do
    test "queue event assert" do
      league_accounts = [
        %{id: 1},
        %{id: 2},
      ]
      LeagueAccountMatchListening.bulk_queue_events(league_accounts)
      assert_enqueued(
        worker: LeagueAccountMatchListening,
        args: %{league_account_id: 1}
      )
      assert_enqueued(
        worker: LeagueAccountMatchListening,
        args: %{league_account_id: 2}
      )
    end

    test "queue uniqueness" do
      league_accounts = [
        %{id: 1},
        %{id: 1}
      ]
      LeagueAccountMatchListening.bulk_queue_events(league_accounts)
      jobs = all_enqueued(worker: LeagueAccountMatchListening)
      assert 1 == length(jobs)
    end
  end
end
