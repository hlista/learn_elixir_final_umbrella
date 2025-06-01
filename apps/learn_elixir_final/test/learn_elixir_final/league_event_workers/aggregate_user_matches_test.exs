defmodule LearnElixirFinal.LeagueEventWorkers.AggregateUserMatchesTest do
  use LearnElixirFinalPg.DataCase
  use Oban.Testing, repo: LearnElixirFinalPg.Repo
  import LearnElixirFinalPg.Factory
  import Mox

  setup :set_mox_from_context

  alias LearnElixirFinal.LeagueEventWorkers.AggregateUserMatches

  @riot_api_key Application.compile_env(:riot_client, :riot_api_key)

  describe "@bulk_queue_events/2" do
    test "queue event assert" do
      AggregateUserMatches.bulk_queue_events([%{id: 2}, %{id: 3}])
      assert_enqueued(worker: AggregateUserMatches, args: %{user_id: 2}, queue: :league_match_aggregate)
      assert_enqueued(worker: AggregateUserMatches, args: %{user_id: 3}, queue: :league_match_aggregate)
    end

    test "queue uniqueness" do
      users = [%{id: 2}, %{id: 2}]
      AggregateUserMatches.bulk_queue_events(users)
      jobs = all_enqueued(worker: AggregateUserMatches)
      assert 1 == length(jobs)
    end
  end
end
