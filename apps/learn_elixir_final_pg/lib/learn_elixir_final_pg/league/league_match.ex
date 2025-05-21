defmodule LearnElixirFinalPg.League.LeagueMatch do
  use Ecto.Schema
  import Ecto.Changeset
  alias LearnElixirFinalPg.League.MatchParticipant

  @required_fields [:match_id, :region]
  @available_fields [
    :game_duration,
    :game_end_timestamp,
    :game_id,
    :game_name,
    :participants
  ] ++ @required_fields

  schema "league_matches" do
    field :match_id, :string
    field :region, :string
    field :game_duration, :integer
    field :game_end_timestamp, :utc_datetime
    field :game_id, :integer
    field :game_name, :string
    field :participants, {:array, :string}
    has_many :match_participants, MatchParticipant
    has_many :users, through: [:match_participants, :users]
    has_many :league_accounts, through: [:match_participants, :league_accounts]
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
