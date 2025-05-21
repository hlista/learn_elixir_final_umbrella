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
end
