defmodule LearnElixirFinal.LeagueAccount do
  alias LearnElixirFinalPg.League

  def add_user_league_account_by_game_name_tag_line(user_id, game_name, tag_line) do
    with {:ok, league_account} <- League.find_or_create_league_account(%{game_name: game_name, tag_line: tag_line}),
         {:ok, _} <-
           League.find_or_create_user_league_account(%{
             user_id: user_id,
             league_account_id: league_account.id
           }) do
      {:ok, league_account}
    end
  end

  def add_user_league_account_by_puuid(user_id, puuid) do
    with {:ok, league_account} <- League.find_or_create_league_account(%{puuid: puuid}),
         {:ok, _} <-
           League.find_or_create_user_league_account(%{
             user_id: user_id,
             league_account_id: league_account.id
           }) do
      {:ok, league_account}
    end
  end

  def remove_user_league_account(user_id, league_account_id) do
    with {:ok, league_account} <- League.find_league_account(%{id: league_account_id}),
         {:ok, user_league_account} <-
           League.find_user_league_account(%{
             user_id: user_id,
             league_account_id: league_account.id
           }),
         {:ok, _} <- League.delete_user_league_account(user_league_account.id) do
      {:ok, league_account}
    end
  end
end
