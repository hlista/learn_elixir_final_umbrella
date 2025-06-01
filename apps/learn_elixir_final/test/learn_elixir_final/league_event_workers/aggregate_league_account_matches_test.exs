defmodule LearnElixirFinal.LeagueEventWorkers.AggregateLeagueAccountMatchesTest do
  use LearnElixirFinalPg.DataCase
  use Oban.Testing, repo: LearnElixirFinalPg.Repo
  import LearnElixirFinalPg.Factory
  import Mox

  setup :set_mox_from_context

  alias LearnElixirFinal.LeagueEventWorkers.AggregateLeagueAccountMatches

  @riot_api_key Application.compile_env(:riot_client, :riot_api_key)

  describe "@bulk_queue_events/2" do
    test "queue event assert" do
      AggregateLeagueAccountMatches.bulk_queue_events([%{id: 2, puuid: "foo"}, %{id: 3, puuid: "bar"}])
      assert_enqueued(worker: AggregateLeagueAccountMatches, args: %{league_account_id: 2}, queue: :league_match_aggregate)
      assert_enqueued(worker: AggregateLeagueAccountMatches, args: %{league_account_id: 3}, queue: :league_match_aggregate)
    end

    test "queue uniqueness" do
      league_accounts = [%{id: 2, puuid: "foo"}, %{id: 2, puuid: "bar"}]
      AggregateLeagueAccountMatches.bulk_queue_events(league_accounts)
      jobs = all_enqueued(worker: AggregateLeagueAccountMatches)
      assert 1 == length(jobs)
    end
  end
end
