defmodule LearnElixirFinalPg.League.LeagueAccount do
  use Ecto.Schema
  import Ecto.Changeset
  alias LearnElixirFinalPg.League.MatchParticipant

  @required_fields []
  @available_fields [
    :match_offset,
    :tag_line,
    :game_name,
    :puuid
  ] ++ @required_fields

  schema "league_accounts" do
    field :tag_line, :string
    field :game_name, :string
    field :puuid, :string
    field :match_offset, :integer, default: 0
    has_many :match_participants,
      MatchParticipant, foreign_key: :puuid, references: :puuid
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
