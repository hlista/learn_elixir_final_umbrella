defmodule LearnElixirFinal.Repo.Migrations.CreateLeagueAccountsTable do
  use Ecto.Migration

  def change do
    create table("league_accounts") do
      add :region, :string
      add :tag_line, :string
      add :game_name, :string
      add :puuid, :string
      add :match_offset, :integer, default: 0

      timestamps()
    end
    create unique_index("league_accounts", [:puuid])
  end
end
