defmodule LearnElixirFinalPg.Repo.Migrations.CreateUserLeagueAccountsTable do
  use Ecto.Migration

  def change do
    create table("user_league_accounts") do
      add :user_id, references("users")
      add :league_account_id, references("league_accounts")

      timestamps()
    end
    create unique_index("user_league_accounts", [:user_id, :league_account_id])
  end
end
