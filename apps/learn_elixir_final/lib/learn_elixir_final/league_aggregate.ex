defmodule LearnElixirFinal.LeagueAggregate do
  alias LearnElixirFinalPg.{
    League,
    Auth
  }
  alias __MODULE__.Participant

  def aggregate_league_account(league_account_id) do
    with {:ok, league_account} <- League.find_league_account(%{id: league_account_id}) do
      league_account
      |> League.preload_thirty_participants()
      |> Map.get(:match_participants, [])
      |> Participant.aggregate_participants()
      |> then(& {:ok, &1})
    end
  end

  def aggregate_user(user_id) do
    with {:ok, user} <- Auth.find_user(%{id: user_id}) do
      user
      |> League.preload_thirty_participants()
      |> Map.get(:match_participants, [])
      |> Participant.aggregate_participants()
      |> then(& {:ok, &1})
    end
  end
end
