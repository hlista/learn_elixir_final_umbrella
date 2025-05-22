defmodule LearnElixirFinalPg.League.LeagueAccount do
  use Ecto.Schema
  import Ecto.Changeset
  alias LearnElixirFinalPg.Accounts.User
  alias LearnElixirFinalPg.League.{
    MatchParticipant,
    UserLeagueAccount,
    LeagueAccountMatchAggregate
  }

  @required_fields []
  @available_fields [
    :match_offset,
    :tag_line,
    :game_name,
    :puuid,
    :region,
    :match_region
  ] ++ @required_fields

  schema "league_accounts" do
    field :puuid, :string
    field :tag_line, :string
    field :game_name, :string
    field :region, :string
    field :match_region, :string
    field :match_offset, :integer, default: 0
    has_many :match_participants,
      MatchParticipant, foreign_key: :puuid, references: :puuid
    many_to_many :users,
                User,
                join_through: UserLeagueAccount,
                join_keys: [league_account_id: :id, user_id: :id]
    has_one :match_aggregate, LeagueAccountMatchAggregate
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
