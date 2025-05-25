defmodule LearnElixirFinal.LeagueAccountTest do
  use LearnElixirFinalPg.DataCase
  import LearnElixirFinalPg.Factory
  alias LearnElixirFinal.LeagueAccount
  setup do
    user = insert(:user, league_accounts: [build(:league_account)])
    %{
      user: user
    }
  end

  test "add_user_league_account_by_game_name_tag_line", %{user: user} do
    assert {:ok, %{
      puuid: nil,
      tag_line: "tagline",
      game_name: "gamename"
    }} = LeagueAccount.add_user_league_account_by_game_name_tag_line(user.id, "gamename", "tagline")
  end

  test "add_user_league_account_by_puuid", %{user: user} do
    assert {:ok, %{
      puuid: "puuid",
      tag_line: nil,
      game_name: nil
    }} = LeagueAccount.add_user_league_account_by_puuid(user.id, "puuid")
  end

  test "remove_user_league_account", %{user: user} do
    user_id = user.id
    %{league_accounts: [%{id: league_account_id} | _]} = user
    {:ok, %{
      id: ^league_account_id
    }} = LeagueAccount.remove_user_league_account(user_id, league_account_id)
  end
end
