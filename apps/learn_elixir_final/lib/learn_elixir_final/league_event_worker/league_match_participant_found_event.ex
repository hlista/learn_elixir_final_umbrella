defmodule LearnElixirFinal.LeagueEventWorker.LeagueMatchParticipantFoundEvent do
  alias LearnElixirFinalPg.League
  def maybe_create_league_match_participant(participant_info) do
    case League.find_match_participant(%{puuid: participant_info.puuid, league_match_id: participant_info.league_match_id}) do
      {:ok, _} -> {:ok, "participant already created"}
      {:error, _} ->
        create_league_match_participant(participant_info)
    end
  end

  def create_league_match_participant(participant_info) do
    with {:ok, league_match_participant} <- League.create_match_participant(participant_info) do
      {:ok, %{
        league_match_participant: league_match_participant
      }}
    end
  end
end
