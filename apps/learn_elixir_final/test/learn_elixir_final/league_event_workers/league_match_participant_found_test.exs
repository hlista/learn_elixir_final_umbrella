defmodule LearnElixirFinal.LeagueEventWorkers.LeagueMatchParticipantFoundTest do
  use LearnElixirFinalPg.DataCase
  use Oban.Testing, repo: LearnElixirFinalPg.Repo
  import LearnElixirFinalPg.Factory
  import Mox

  setup :set_mox_from_context

  alias LearnElixirFinal.LeagueEventWorkers.LeagueMatchParticipantFound

  @riot_api_key Application.compile_env(:riot_client, :riot_api_key)

  describe "@bulk_queue_events/2" do
    test "queue event assert" do
      match_participant = params_for(:match_participant)
      match_participants = [match_participant]
      LeagueMatchParticipantFound.bulk_queue_events(match_participants, "europe")
      assert_enqueued worker: LeagueMatchParticipantFound, args: %{participant: match_participant}, queue: :league_match_participant_europe
    end

    test "queue uniqueness" do
      match_participant = params_for(:match_participant)
      match_participants = [match_participant, match_participant]
      LeagueMatchParticipantFound.bulk_queue_events(match_participants, "americas")
      jobs = all_enqueued(worker: LeagueMatchParticipantFound)
      assert 1 == length(jobs)
    end
  end
end
