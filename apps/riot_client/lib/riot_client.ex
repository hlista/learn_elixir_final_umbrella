defmodule RiotClient do
  alias RiotClient.HttpQueue
  alias RiotClient.RealHttpClient

  defp riot_api_key, do: Application.get_env(:riot_client, :riot_api_key)
  def get_account_by_riot_id(game_name, tag_line, region \\ "americas") do
    req = %{
      method: :get,
      url: "https://#{region}.api.riotgames.com/riot/account/v1/accounts/by-riot-id/#{game_name}/#{tag_line}?api_key=#{riot_api_key()}",
      headers: [],
      body: "",
      opts: [],
      region: region
    }
    case HttpQueue.enqueue_request(req) do
      {:ok, %{status: 200, body: body}} ->
        Jason.decode(body)
      {:ok, %{body: body}} ->
        handle_error_code(Jason.decode!(body))
      e -> e
    end
  end

  def get_account_by_puuid(puuid, region \\ "americas") do
    req = %{
      method: :get,
      url: "https://#{region}.api.riotgames.com/riot/account/v1/accounts/by-puuid/#{puuid}?api_key=#{riot_api_key()}",
      headers: [],
      body: "",
      opts: [],
      region: region
    }
    case HttpQueue.enqueue_request(req) do
      {:ok, %{status: 200, body: body}} ->
        Jason.decode(body)
      {:ok, %{body: body}} ->
        handle_error_code(Jason.decode!(body))
      e -> e
    end
  end

  def get_account_region(puuid, region \\ "americas") do
    req = %{
      method: :get,
      url: "https://#{region}.api.riotgames.com/riot/account/v1/region/by-game/lol/by-puuid/#{puuid}?api_key=#{riot_api_key()}",
      headers: [],
      body: "",
      opts: [],
      region: region
    }
    case HttpQueue.enqueue_request(req) do
      {:ok, %{status: 200, body: body}} ->
        Jason.decode(body)
     {:ok, %{body: body}} ->
        handle_error_code(Jason.decode!(body))
      e -> e
    end
  end

  def get_account_match_ids(puuid, start, count \\ 20, region \\ "americas") do
    req = %{
      method: :get,
      url: "https://#{region}.api.riotgames.com/lol/match/v5/matches/by-puuid/#{puuid}/ids?start=#{start}&count=#{count}&api_key=#{riot_api_key()}",
      headers: [],
      body: "",
      opts: [],
      region: region
    }
    case HttpQueue.enqueue_request(req) do
      {:ok, %{status: 200, body: body}} ->
        Jason.decode(body)
      {:ok, %{body: body}} ->
        handle_error_code(Jason.decode!(body))
      e -> e
    end
  end

  def get_match(match_id, region \\ "americas") do
    req = %{
      method: :get,
      url: "https://#{region}.api.riotgames.com/lol/match/v5/matches/#{match_id}?api_key=#{riot_api_key()}",
      headers: [],
      body: "",
      opts: [],
      region: region
    }
    case HttpQueue.enqueue_request(req) do
      {:ok, %{status: 200, body: body}} ->
        Jason.decode(body)
      {:ok, %{body: body}} ->
        handle_error_code(Jason.decode!(body))
      e -> e
    end
  end

  def handle_error_code(%{
    "status" => %{
      "message" => "Unknown apikey",
      "status_code" => 401
  }}) do
    {:error, "Invalid Api Key"}
  end

  def handle_error_code(%{
    "status" => %{
      "message" => "Bad Request - Exception decrypting" <> _,
      "status_code" => 400
  }}) do
    {:error, "Invalid player"}
  end

  def handle_error_code(%{
    "status" => %{
      "message" => "Data not found - No results found for player" <> _,
      "status_code" => 404
    }
  }) do
    {:error, "Invalid player"}
  end

  def handle_error_code(%{
    "errorCode" => "RESOURCE_NOT_FOUND",
    "httpStatus" => 404,
  }) do
    {:error, "resource not found"}
  end

  def handle_error_code(body) do
    {:error, body}
  end
end
