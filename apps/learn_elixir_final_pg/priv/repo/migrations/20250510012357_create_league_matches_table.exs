defmodule LearnElixirFinalPg.Repo.Migrations.CreateLeagueMatchesTable do
  use Ecto.Migration

  def change do
    create table("league_matches") do
      add :match_id, :string
      add :region, :string
      add :game_duration, :integer
      add :game_end_timestamp, :integer
      add :game_id, :integer
      add :game_name, :string
      add :participants, {:array, :string}
      timestamps()
    end
    create unique_index("league_matches", [:match_id])
  end
end
