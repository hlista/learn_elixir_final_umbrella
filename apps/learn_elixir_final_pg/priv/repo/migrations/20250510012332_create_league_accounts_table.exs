defmodule LearnElixirFinalPg.Repo.Migrations.CreateLeagueAccountsTable do
  use Ecto.Migration

  def change do
    create table("league_accounts") do
      add :puuid, :string
      add :tag_line, :string
      add :game_name, :string
      add :region, :string
      add :match_region, :string
      add :match_offset, :integer, default: 0

      timestamps()
    end
    create unique_index("league_accounts", [:puuid])
  end
end
