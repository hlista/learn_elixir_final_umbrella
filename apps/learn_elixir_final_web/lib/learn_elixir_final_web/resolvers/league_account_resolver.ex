defmodule LearnElixirFinalWeb.Resolvers.LeagueAccountResolver do
  alias LearnElixirFinalWeb.LearnElixirFinalProxy
  def add_summoner_by_game_name_tag_line(%{
    tag_line: tag_line,
    game_name: game_name
  }, %{context: %{current_user: current_user}}) do
    LearnElixirFinalProxy.add_user_league_account_by_game_name_tag_line(current_user.id, game_name, tag_line)
  end

  def add_summoner_by_puuid(%{
    puuid: puuid
  }, %{context: %{current_user: current_user}}) do
    LearnElixirFinalProxy.add_user_league_account_by_puuid(current_user.id, puuid)
  end

  def remove_summoner(%{
    league_account_id: league_account_id
  }, %{context: %{current_user: current_user}}) do
    LearnElixirFinalProxy.remove_user_league_account(current_user.id, league_account_id)
  end
end
