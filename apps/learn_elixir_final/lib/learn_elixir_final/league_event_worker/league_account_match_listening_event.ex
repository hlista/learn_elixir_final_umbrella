defmodule LearnElixirFinal.LeagueEventWorker.LeagueAccountMatchListeningEvent do
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

  def find_league_account_matches(puuid, region) do
    with {:ok, league_account} <- League.find_league_account(%{puuid: puuid}),
         {:ok, match_ids} <- RiotClient.get_account_match_ids(region, puuid, league_account.match_offset, 20),
         {:ok, _} <- League.update_league_account(league_account, %{match_offset: league_account.match_offset + length(match_ids)}) do
           {:ok, match_ids}
    end
  end

  def find_and_create_league_account(puuid) do
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
