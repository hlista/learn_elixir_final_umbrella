defmodule LearnElixirFinal.LeagueEventWorker.LeagueAccountDiscoveredEvent do
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

  def create_league_account_by_puuid(puuid) do
    with {:ok, %{
      "gameName" => game_name,
      "tagLine" => tag_line
    }} <- RiotClient.get_account_by_puuid(puuid),
    {:ok, %{
      "region" => region
    }} <- RiotClient.get_account_region(puuid),
    {:ok, match_region} <- find_match_region(region) do
      LearnElixirFinalPg.League.find_and_upsert_league_account(%{
        puuid: puuid
      }, %{
        game_name: game_name,
        tag_line: tag_line,
        region: region,
        match_region: match_region
      })
    end
  end

  def create_league_account_by_game_name_tag_line(game_name, tag_line) do
    with {:ok, %{
      "puuid" => puuid
    }} <- RiotClient.get_account_by_riot_id(game_name, tag_line),
    {:ok, %{
      "region" => region
    }} <- RiotClient.get_account_region(puuid),
    {:ok, match_region} <- find_match_region(region) do
      League.find_and_upsert_league_account(%{
        game_name: game_name,
        tag_line: tag_line
      }, %{
        puuid: puuid,
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
