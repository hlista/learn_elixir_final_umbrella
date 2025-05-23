defmodule LearnElixirFinalPg.Repo.Migrations.LeagueAccountsGameNameTagLineUniqueIndex do
  use Ecto.Migration

  def change do
    create unique_index("league_accounts", [:game_name, :tag_line])
  end
end
