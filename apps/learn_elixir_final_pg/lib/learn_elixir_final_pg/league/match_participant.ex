defmodule LearnElixirFinalPg.League.MatchParticipant do
  use Ecto.Schema
  import Ecto.Changeset
  alias LearnElixirFinalPg.League.LeagueMatch

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
    field :damage_dealt_to_buildings, :integer
    field :damage_dealt_to_objectives, :integer
    field :damage_dealt_to_turrets, :integer
    field :damage_self_mitigated, :integer
    field :deaths, :integer
    field :gold_earned, :integer
    field :gold_spent, :integer
    field :kills, :integer
    field :largest_killing_spree, :integer
    field :largest_multi_kill, :integer
    field :magic_damage_dealt, :integer
    field :magic_damage_dealt_to_champions, :integer
    field :magic_damage_taken, :integer
    field :physical_damage_dealt, :integer
    field :physical_damage_dealt_to_champions, :integer
    field :physical_damage_taken, :integer
    field :total_damage_dealt, :integer
    field :total_damage_dealt_to_champions, :integer
    field :total_damage_taken, :integer
    field :total_heal, :integer
    field :total_minions_killed, :integer
    field :total_time_spent_dead, :integer
    field :win, :boolean
    belongs_to :league_match, LeagueMatch
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
