defmodule LearnElixirFinal.LeagueAccount do
  alias LearnElixirFinalPg.League

  @platform_to_region_routing_table %{
    "na" => "americas",
    "br" => "americas",
    "lan" => "americas",
    "las" => "americas",
    "kr" => "asia",
    "jp" => "asia",
    "eune" => "europe",
    "euw" => "europe",
    "me" => "europe",
    "tr" => "europe",
    "ru" => "europe",
    "oce" => "sea",
    "sg" => "sea",
    "tw" => "sea",
    "vn" => "sea"
  }

  def find_or_create_league_account(puuid) do
    case League.find_league_account(%{puuid: puuid}) do
      {:error, _} ->
        create_league_account(puuid)
      found -> found
    end
  end

  def find_or_create_league_account(game_name, tag_line) do
    case League.find_league_account(%{game_name: game_name, tag_line: tag_line}) do
      {:error, _} ->
        create_league_account(game_name, tag_line)
      found -> found
    end
  end

  def create_league_account(game_name, tag_line) do
    with {:ok, %{
      "puuid" => puuid
    }} <- RiotClient.get_account_by_riot_id(game_name, tag_line),
    {:ok, %{
      "region" => region
    }} <- RiotClient.get_account_region(puuid),
    {:ok, match_region} <- find_match_region(region) do
      LearnElixirFinalPg.League.create_league_account(%{
        puuid: puuid,
        game_name: game_name,
        tag_line: tag_line,
        region: region,
        match_region: match_region
      })
    end
  end

  def create_league_account(puuid) do
    with {:ok, %{
      "gameName" => game_name,
      "tagLine" => tag_line
    }} <- RiotClient.get_account_by_puuid(puuid),
    {:ok, %{
      "region" => region
    }} <- RiotClient.get_account_region(puuid),
    {:ok, match_region} <- find_match_region(region) do
      LearnElixirFinalPg.League.create_league_account(%{
        puuid: puuid,
        game_name: game_name,
        tag_line: tag_line,
        region: region,
        match_region: match_region
      })
    end
  end

  def find_match_region(region) do
    region_abbreviation = String.replace(region, ~r/\d/, "")
    case @platform_to_region_routing_table[region_abbreviation] do
      nil ->
        {:error, "Region not found"}
      region ->
        {:ok, region}
    end
  end

  def add_user_league_account_by_game_name_tag_line(user_id, game_name, tag_line) do
    with {:ok, league_account} <- find_or_create_league_account(game_name, tag_line),
         {:ok, _} <- League.find_or_create_user_league_account(%{user_id: user_id, league_account_id: league_account.id}) do
      {:ok, league_account}
    end
  end

  def add_user_league_account_by_puuid(user_id, puuid) do
    with {:ok, league_account} <- find_or_create_league_account(puuid),
    {:ok, _} <- League.find_or_create_user_league_account(%{user_id: user_id, league_account_id: league_account.id}) do
      {:ok, league_account}
    end
  end

  def remove_user_league_account(user_id, puuid) do
    with {:ok, league_account} <- League.find_league_account(%{puuid: puuid}),
         {:ok, user_league_account} <- League.find_user_league_account(%{user_id: user_id, league_account_id: league_account.id}),
         {:ok, _} <- League.delete_user_league_account(user_league_account.id) do
      {:ok, league_account}
    end
  end
end
