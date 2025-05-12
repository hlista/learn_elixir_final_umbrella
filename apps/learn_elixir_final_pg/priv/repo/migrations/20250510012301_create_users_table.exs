defmodule LearnElixirFinalPg.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table("users") do
      add :email, :string
      add :password_digest, :string
      add :enabled, :boolean, default: false

      timestamps()
    end
    create unique_index("users", [:email])
  end
end
