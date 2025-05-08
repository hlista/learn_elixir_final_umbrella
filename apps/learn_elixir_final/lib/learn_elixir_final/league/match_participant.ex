defmodule LearnElixirFinal.League.MatchParticipant do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:match_id]
  @available_fields [
    :game_duration,
    :game_end_timestamp,
    :game_id,
    :game_name
  ] ++ @required_fields

  schema "match_participants" do
    field :puuid, :string
    field :assists, :integer
    field :baron_kills, :integer
    field :champ_experience, :integer
    field :champ_level, :integer
    field :champion_name, :string
    field :damageDealtToBuildings, :integer
    field :damageDealtToObjectives, :integer
    field :damageDealtToTurrets, :integer
    field :damageSelfMitigated, :integer
    field :deaths, :integer
    field :goldEarned, :integer
    field :goldSpent, :integer
    field :kills, :integer
    field :largestKillingSpree, :integer
    field :largestMultiKill, :integer
    field :magicDamageDealt, :integer
    field :magicDamageDealtToChampions, :integer
    field :magicDamageTaken, :integer
    field :physicalDamageDealt, :integer
    field :physicalDamageDealtToChampions, :integer
    field :physicalDamageTaken, :integer
    field :totalDamageDealt, :integer
    field :totalDamageDealtToChampions, :integer
    field :totalDamageTaken, :integer
    field :totalHeal, :integer
    field :totalMinionsKilled, :integer
    field :totalTimeSpentDead, :integer
    field :win, :boolean
    belongs_to :league_match, LearnElixirFinal.League.LeagueMatch
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
