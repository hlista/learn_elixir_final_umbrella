defmodule LearnElixirFinal.RiotClient do
  @api_key "RGAPI-9c48c3b4-384c-4aa6-8152-9b85a7837457"
  alias LearnElixirFinal.HttpQueue
  alias LearnElixirFinal.RealHttpClient
  def get_account_by_riot_id(region, game_name, tag_line) do
    req = %{
      method: :get,
      url: "https://#{region}.api.riotgames.com/riot/account/v1/accounts/by-riot-id/#{game_name}/#{tag_line}?api_key=#{@api_key}",
      headers: [],
      body: "",
      opts: [],
      client: RealHttpClient
    }
    case HttpQueue.enqueue_request(req) do
      {:ok, %{status: 200, body: body}} ->
        Jason.decode(body)
      e -> e
    end
  end

  def get_match_ids(region, puuid, start, count \\ 20) do
    req = %{
      method: :get,
      url: "https://#{region}.api.riotgames.com/lol/match/v5/matches/by-puuid/#{puuid}/ids?start=#{start}&count=#{count}&api_key=#{@api_key}",
      headers: [],
      body: "",
      opts: [],
      client: RealHttpClient
    }
    case HttpQueue.enqueue_request(req) do
      {:ok, %{status: 200, body: body}} ->
        Jason.decode(body)
      e -> e
    end
  end
end
