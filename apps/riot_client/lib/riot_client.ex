defmodule RiotClient do
  alias RiotClient.HttpQueue
  alias RiotClient.RealHttpClient

  defp riot_api_key, do: Application.get_env(:riot_client, :riot_api_key)
  def get_account_by_riot_id(region \\ "americas", game_name, tag_line) do
    req = %{
      method: :get,
      url: "https://#{region}.api.riotgames.com/riot/account/v1/accounts/by-riot-id/#{game_name}/#{tag_line}?api_key=#{riot_api_key()}",
      headers: [],
      body: "",
      opts: [],
      client: RealHttpClient,
      region: region
    }
    case HttpQueue.enqueue_request(req) do
      {:ok, %{status: 200, body: body}} ->
        Jason.decode(body)
      e -> e
    end
  end

  def get_account_by_puuid(region \\ "americas", puuid) do
    req = %{
      method: :get,
      url: "https://#{region}.api.riotgames.com/riot/account/v1/accounts/by-puuid/#{puuid}?api_key=#{riot_api_key()}",
      headers: [],
      body: "",
      opts: [],
      client: RealHttpClient,
      region: region
    }
    case HttpQueue.enqueue_request(req) do
      {:ok, %{status: 200, body: body}} ->
        Jason.decode(body)
      e -> e
    end
  end

  def get_account_region(region \\ "americas", puuid) do
    req = %{
      method: :get,
      url: "https://#{region}.api.riotgames.com/riot/account/v1/region/by-game/lol/by-puuid/#{puuid}?api_key=#{riot_api_key()}",
      headers: [],
      body: "",
      opts: [],
      client: RealHttpClient,
      region: region
    }
    case HttpQueue.enqueue_request(req) do
      {:ok, %{status: 200, body: body}} ->
        Jason.decode(body)
      e -> e
    end
  end

  def get_account_match_ids(region \\ "americas", puuid, start, count \\ 20) do
    req = %{
      method: :get,
      url: "https://#{region}.api.riotgames.com/lol/match/v5/matches/by-puuid/#{puuid}/ids?start=#{start}&count=#{count}&api_key=#{riot_api_key()}",
      headers: [],
      body: "",
      opts: [],
      client: RealHttpClient,
      region: region
    }
    case HttpQueue.enqueue_request(req) do
      {:ok, %{status: 200, body: body}} ->
        Jason.decode(body)
      e -> e
    end
  end

  def get_match(region \\ "americas", match_id) do
    req = %{
      method: :get,
      url: "https://#{region}.api.riotgames.com/lol/match/v5/matches/#{match_id}?api_key=#{riot_api_key()}",
      headers: [],
      body: "",
      opts: [],
      client: RealHttpClient,
      region: region
    }
    case HttpQueue.enqueue_request(req) do
      {:ok, %{status: 200, body: body}} ->
        Jason.decode(body)
      e -> e
    end
  end
end
