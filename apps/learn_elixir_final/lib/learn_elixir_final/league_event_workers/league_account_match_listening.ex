defmodule LearnElixirFinal.LeagueEventWorkers.LeagueAccountMatchListening do
  use Oban.Worker,
  queue: :league_listening,
  unique: [
    period: {2, :minutes},
    timestamp: :scheduled_at,
    fields: [:worker, :args]
  ],
  max_attempts: 5
  alias LearnElixirFinalPg.League
  alias LearnElixirFinal.LeagueEventWorkers.LeagueMatchFound

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

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: params
      }) do
    params = %{
      id: params["league_account_id"],
      puuid: params["puuid"]
    }
    params = Map.filter(params, & elem(&1, 1))
    case find_league_account_matches(params) do
      {:ok, %{
        match_ids: match_ids,
        league_account: league_account
      }} ->
        LeagueMatchFound.bulk_queue_events(match_ids, league_account.match_region)
      {:error, "Invalid player"} -> {:ok, "Player does not exist"}
      {:error, "Invalid region"} -> {:ok, "Region does not exist"}
      {:error, "Invalid Api Key"} -> {:ok, "Api Key expired"}
      {:error, "Invalid account params"} -> {:ok, "Invalid account params"}
      {:error, %{code: :not_found}} -> {:ok, "Player does not exist"}
      e -> e
    end
  end

  def queue_event(params) do
    params
    |> __MODULE__.new()
    |> Oban.insert()
  end


  def bulk_queue_events(league_accounts) do
    Enum.each(league_accounts, fn league_account ->
      queue_event(%{league_account_id: league_account.id})
    end)
  end

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
         {:ok, _} <- League.update_league_account(league_account, %{match_offset: calculate_new_match_offset(league_account.match_offset, length(match_ids))}) do
           {:ok, %{
            match_ids: match_ids,
            league_account: league_account
           }}
    end
  end

  defp calculate_new_match_offset(curr_match_offset, new_match_count) do
    new_match_offset = curr_match_offset + new_match_count
    if new_match_offset >= 30 do
      0
    else
      new_match_offset
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
