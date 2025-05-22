defmodule LearnElixirFinalWeb.Resolvers.LeagueAccountResolver do
  alias LearnElixirFinalWeb.LearnElixirFinalProxy
  def add_summoner_by_game_name_tag_line(%{
    tag_line: tag_line,
    game_name: game_name
  }, %{current_user: user}) do
    LearnElixirFinalProxy.add_user_league_account_by_game_name_tag_line(user.id, game_name, tag_line)
  end

  def add_summoner_by_puuid(%{
    puuid: puuid
  }, %{current_user: user}) do
    LearnElixirFinalProxy.add_user_league_account_by_puuid(user.id, puuid)
  end

  def remove_summoner(%{
    puuid: puuid
  }, %{current_user: user}) do
    LearnElixirFinalProxy.remove_user_league_account(user.id, puuid)
  end
end
