defmodule LearnElixirFinal.LeagueEventWorker.UserMatchListeningEvent do
  alias LearnElixirFinalPg.Accounts

  def find_user_league_accounts(user_id) do
    with {:ok, user} <- Accounts.find_user(%{id: user_id, preload: :league_accounts}) do
      {:ok, user.league_accounts}
    end
  end
end
