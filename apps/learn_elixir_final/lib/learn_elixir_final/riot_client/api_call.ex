defmodule LearnElixirFinal.RiotClient.ApiCall do
  @api_key Application.get_env(:learn_elixir_final, :riot_api_key)
  def get_account_by_riot_id(region, game_name, tag_line) do
    Finch.build(:get, "https://#{region}.api.riotgames.com/riot/account/v1/accounts/by-riot-id/#{game_name}/#{tag_line}?api_key=#{@api_key}")
    |> Finch.request(MyFinch)
  end
end
