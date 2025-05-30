defmodule LearnElixirFinalPg.League.UserLeagueAccount do
  use Ecto.Schema
  import Ecto.Changeset
  alias LearnElixirFinalPg.Accounts.User
  alias LearnElixirFinalPg.League.LeagueAccount

  @required_fields [
    :user_id,
    :league_account_id
  ]
  @available_fields @required_fields

  schema "user_league_accounts" do
    belongs_to :user, User
    belongs_to :league_account, LeagueAccount
    timestamps()
  end

  def create_changeset(params) do
    changeset(%__MODULE__{}, params)
  end

  @doc false
  def changeset(preference, attrs) do
    preference
    |> cast(attrs, @available_fields)
    |> validate_required(@required_fields)
  end
end
