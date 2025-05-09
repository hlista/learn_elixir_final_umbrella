defmodule LearnElixirFinalWeb.Resolvers.LeagueAccountResolver do
  alias LearnElixirFinal.RiotClient
  alias LearnElixirFinal.Leagues
  def add_summoner(%{
    region: region,
    tag_line: tag_line,
    game_name: game_name
  }, %{current_user: user}) do
    with {:ok, %{"puuid" => puuid}} <- RiotClient.get_account_by_riot_id(region, game_name, tag_line),
      {:ok, league_account} <- Leagues.find_or_create_league_account(%{
        region: region,
        tag_line: tag_line,
        game_name: game_name,
        puuid: puuid
      }),
      {:ok, _} <- Leagues.create_user_league_account(%{user_id: user.id, league_account_id: league_account.id}),
      {:ok, _} <- LearnElixirFinal.LeagueAccountWorker.queue_account(league_account) do
        {:ok, league_account}
    end
  end

  def remove_summoner(_, _) do

  end
end
