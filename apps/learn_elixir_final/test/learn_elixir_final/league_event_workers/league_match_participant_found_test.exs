defmodule LearnElixirFinal.LeagueEventWorkers.LeagueMatchParticipantFoundTest do
  use LearnElixirFinalPg.DataCase
  use Oban.Testing, repo: LearnElixirFinalPg.Repo
  import LearnElixirFinalPg.Factory
  import Mox

  setup :set_mox_from_context

  alias LearnElixirFinal.LeagueEventWorkers.{
    AggregateLeagueAccountMatches,
    LeagueMatchParticipantFound
  }

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

  describe "perform league_match_participant_found_event" do
    test "Success" do
      league_match = insert(:league_match, region: "asia")
      match_participant = params_for(:match_participant, league_match_id: league_match.id)
      league_account = insert(:league_account, puuid: match_participant.puuid)
      :ok = perform_job(
        LeagueMatchParticipantFound,
        %{
          participant: match_participant,
          region: league_match.region
        }, queue: :league_match_participant_asia
      )
      assert_enqueued(worker: AggregateLeagueAccountMatches, args: %{league_account_id: league_account.id})
    end

    test "create league account if doesnt exist" do
      league_match = insert(:league_match, region: "asia")
      match_participant = params_for(:match_participant, league_match_id: league_match.id)
      assert :ok = perform_job(
        LeagueMatchParticipantFound,
        %{
          participant: match_participant,
          region: league_match.region,
        }, queue: :league_match_participant_asia
      )
      jobs = all_enqueued(worker: AggregateLeagueAccountMatches)
      assert 1 == length(jobs)
    end
  end
end
