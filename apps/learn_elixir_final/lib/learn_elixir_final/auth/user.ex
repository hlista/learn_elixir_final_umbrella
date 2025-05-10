defmodule LearnElixirFinal.Auth.User do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:email, :password]
  @available_fields [:enabled] ++ @required_fields

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :password_digest, :string, redact: true
    field :enabled, :boolean, default: false
    many_to_many :league_accounts,
                 LearnElixirFinal.League.LeagueAccount,
                 join_through: LearnElixirFinal.League.UserLeagueAccount,
                 join_keys: [user_id: :id, league_account_id: :id]
    has_many :match_participants, through: [:league_accounts, :match_participants]
    timestamps()
  end

  def create_changeset(params) do
    changeset(%__MODULE__{}, params)
  end

  @doc false
  def changeset(preference, attrs) do
    preference
    |> cast(attrs, @required_fields)
    |> validate_required(@available_fields)
  end
end
