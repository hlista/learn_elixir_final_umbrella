defmodule LearnElixirFinal.LeagueEventWorker.LeagueMatchParticipantFoundEvent do
  alias LearnElixirFinalPg.League
  def maybe_create_league_match_participant(participant_info) do
    participant_info = participant_info
    |> Enum.map(fn {k, v} -> {String.to_existing_atom(k), v} end)
    |> Enum.into(%{})
    case League.find_match_participant(%{puuid: participant_info.puuid, league_match_id: participant_info.league_match_id}) do
      {:ok, _} -> {:ok, "participant already created"}
      {:error, _} ->
        create_league_match_participant(participant_info)
    end
  end

  def create_league_match_participant(participant_info) do
    with {:ok, league_match_participant} <- League.create_match_participant(participant_info) do
      %{users: users, league_accounts: league_accounts} = League.preload_match_participants_users_and_league_accounts(league_match_participant)
      {:ok, %{
        league_match_participant: league_match_participant,
        users: users,
        league_accounts: league_accounts
      }}
    end
  end
end
