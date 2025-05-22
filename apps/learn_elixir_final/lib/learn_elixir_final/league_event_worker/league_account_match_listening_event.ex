defmodule LearnElixirFinal.LeagueEventWorker.LeagueAccountMatchListeningEvent do
  alias LearnElixirFinalPg.League

  def find_league_account_matches(league_account) do
    with {:ok, match_ids} <- RiotClient.get_account_match_ids(league_account.match_region, league_account.puuid, league_account.match_offset, 5),
         {:ok, _} <- League.update_league_account(league_account, %{match_offset: league_account.match_offset + length(match_ids)}) do
           {:ok, match_ids}
    end
  end
end
