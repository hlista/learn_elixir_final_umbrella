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

  def find_or_create_league_account(%{id: _} = params) do
    with {:ok, league_account} <- League.find_league_account(params) do
      riot_update_league_account(league_account)
    end
  end

  def find_or_create_league_account(params) do
    case League.find_league_account(params) do
      {:error, _} ->
        create_league_account(params)

      {:ok, league_account} ->
        riot_update_league_account(league_account)
    end
  end

  def create_league_account(params) do
    with {:ok, league_account} <- League.create_league_account(params) do
      riot_update_league_account(league_account)
    end
  end

  def riot_update_league_account(%{puuid: nil, game_name: nil, tag_line: nil}) do
    {:error, "League Account must have a puuid or game_name/tag_line"}
  end

  def riot_update_league_account(%{id: id, puuid: nil, game_name: game_name, tag_line: tag_line}) do
    with {:ok,
          %{
            "puuid" => puuid
          }} <- RiotClient.get_account_by_riot_id(game_name, tag_line),
         {:ok, league_account} <-
           League.update_league_account(id, %{
             puuid: puuid
           }) do
      riot_update_league_account(league_account)
    end
  end

  def riot_update_league_account(%{id: id, puuid: puuid, game_name: nil, tag_line: nil}) do
    with {:ok,
          %{
            "gameName" => game_name,
            "tagLine" => tag_line
          }} <- RiotClient.get_account_by_puuid(puuid),
         {:ok, league_account} <-
           League.update_league_account(id, %{game_name: game_name, tag_line: tag_line}) do
      riot_update_league_account(league_account)
    end
  end

  def riot_update_league_account(%{id: id, puuid: puuid, match_region: nil}) do
    with {:ok, %{"region" => region}} <- RiotClient.get_account_region(puuid),
         {:ok, match_region} <- find_match_region(region),
         {:ok, league_account} <-
           League.update_league_account(id, %{region: region, match_region: match_region}) do
      riot_update_league_account(league_account)
    end
  end

  def riot_update_league_account(league_account) do
    {:ok, league_account}
  end

  def find_league_account_matches(league_account_params) when map_size(league_account_params) != 0 do
    with {:ok, league_account} <- find_or_create_league_account(league_account_params),
         {:ok, match_ids} <- RiotClient.get_account_match_ids(league_account.puuid, league_account.match_offset, 5, league_account.match_region),
         {:ok, _} <- League.update_league_account(league_account, %{match_offset: league_account.match_offset + length(match_ids)}) do
           {:ok, %{
            match_ids: match_ids,
            league_account: league_account
           }}
    end
  end

  def find_league_account_matches(_) do
    {:error, "Invalid account params"}
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
