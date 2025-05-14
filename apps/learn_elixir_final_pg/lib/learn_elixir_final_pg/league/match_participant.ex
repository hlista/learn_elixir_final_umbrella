defmodule LearnElixirFinalPg.League.MatchParticipant do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias LearnElixirFinalPg.League.LeagueMatch

  @required_fields [
    :puuid,
    :league_match_id,
    :game_end_timestamp
  ]
  @available_fields [
    :assists,
    :baron_kills,
    :champ_experience,
    :champ_level,
    :champion_name,
    :damage_dealt_to_buildings,
    :damage_dealt_to_objectives,
    :damage_dealt_to_turrets,
    :damage_self_mitigated,
    :deaths,
    :gold_earned,
    :gold_spent,
    :kills,
    :largest_killing_spree,
    :largest_multi_kill,
    :magic_damage_dealt,
    :magic_damage_dealt_to_champions,
    :magic_damage_taken,
    :physical_damage_dealt,
    :physical_damage_dealt_to_champions,
    :physical_damage_taken,
    :total_damage_dealt,
    :total_damage_dealt_to_champions,
    :total_damage_taken,
    :total_heal,
    :total_minions_killed,
    :total_time_spent_dead,
    :win
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
    field :game_end_timestamp, :utc_datetime
    belongs_to :league_match, LeagueMatch
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

  def last_thirty_query() do
    __MODULE__
    |> limit(30)
    |> order_by([desc: :game_end_timestamp])
  end
end
