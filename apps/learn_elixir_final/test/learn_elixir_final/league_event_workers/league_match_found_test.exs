defmodule LearnElixirFinal.LeagueEventWorkers.LeagueMatchFoundTest do
  use LearnElixirFinalPg.DataCase
  use Oban.Testing, repo: LearnElixirFinalPg.Repo
  import LearnElixirFinalPg.Factory
  import Mox

  setup :set_mox_from_context

  alias LearnElixirFinal.LeagueEventWorkers.LeagueMatchFound

  @riot_api_key Application.compile_env(:riot_client, :riot_api_key)

  describe "@bulk_queue_events/2" do
    test "queue event assert" do
      match_ids = ["match_1", "match_2", "match_3"]
      LeagueMatchFound.bulk_queue_events(match_ids, "asia")
      assert_enqueued worker: LeagueMatchFound, args: %{match_id: "match_1"}, queue: :league_match_found_asia
      assert_enqueued worker: LeagueMatchFound, args: %{match_id: "match_2"}, queue: :league_match_found_asia
      assert_enqueued worker: LeagueMatchFound, args: %{match_id: "match_3"}, queue: :league_match_found_asia
    end

    test "queue uniqueness" do
      match_ids = ["match_1", "match_1"]
      LeagueMatchFound.bulk_queue_events(match_ids, "americas")
      jobs = all_enqueued(worker: LeagueMatchFound)
      assert 1 == length(jobs)
    end
  end
end
