defmodule LearnElixirFinal.LeagueEventWorkerTest do
  use LearnElixirFinalPg.DataCase
  use Oban.Testing, repo: LearnElixirFinalPg.Repo

  alias LearnElixirFinal.LeagueEventWorker

  describe "queue_league_account_match_listening_event" do
    setup do
      %{
        puuid: "foobar"
      }
    end
    test "queue event assert", %{puuid: puuid} do
      assert {:ok, %Oban.Job{
        state: "available",
        queue: "league_events_americas",
        worker: "LearnElixirFinal.LeagueEventWorker",
        args: %{puuid: ^puuid, event: "league_account_match_listening_event"}
      }} = LeagueEventWorker.queue_league_account_match_listening_event(puuid)
    end
  end
end
