defmodule LearnElixirFinal.LeagueEventWorkers.UserMatchListeningTest do
  use LearnElixirFinalPg.DataCase
  use Oban.Testing, repo: LearnElixirFinalPg.Repo
  import LearnElixirFinalPg.Factory
  import Mox

  setup :set_mox_from_context

  alias LearnElixirFinal.LeagueEventWorkers.UserMatchListening

  @riot_api_key Application.compile_env(:riot_client, :riot_api_key)

  describe "@queue_event/1" do
    test "queue event assert" do
      UserMatchListening.queue_event(5)
      assert_enqueued worker: UserMatchListening, args: %{user_id: 5}
    end

    test "queue uniqueness"  do
      UserMatchListening.queue_event(5)
      UserMatchListening.queue_event(5)
      jobs = all_enqueued(worker: UserMatchListening)
      assert 1 == length(jobs)
    end

    test "queue not unique" do
      UserMatchListening.queue_event(5)
      UserMatchListening.queue_event(6)
      jobs = all_enqueued(worker: UserMatchListening)
      assert 2 == length(jobs)
    end
  end

end
