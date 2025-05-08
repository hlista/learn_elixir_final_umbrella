defmodule LearnElixirFinal.RiotClient do
  @api_key "RGAPI-f4a6853c-171d-4d0e-b226-ea0a48fdf704"
  alias LearnElixirFinal.HttpQueue
  def get_account_by_riot_id(region, game_name, tag_line) do
    url = "https://#{region}.api.riotgames.com/riot/account/v1/accounts/by-riot-id/#{game_name}/#{tag_line}?api_key=#{@api_key}"
    case HttpQueue.enqueue(url) do
      {:ok, %{status: 200, body: body}} ->
        Jason.decode(body)
      e -> e
    end
  end
end
