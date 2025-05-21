defmodule LearnElixirFinalPg.League.LeagueAccountMatchAggregate do
  use Ecto.Schema
  import Ecto.Changeset
  alias LearnElixirFinalPg.League.LeagueAccount

  @required_fields [
    :league_account_id
  ]
  @available_fields [
    :avg_assists,
    :avg_baron_kills,
    :avg_champ_experience,
    :avg_champ_level,
    :avg_damage_dealt_to_buildings,
    :avg_damage_dealt_to_objectives,
    :avg_damage_dealt_to_turrets,
    :avg_damage_self_mitigated,
    :avg_deaths,
    :avg_gold_earned,
    :avg_gold_spent,
    :avg_kills,
    :avg_largest_killing_spree,
    :avg_largest_multi_kill,
    :avg_magic_damage_dealt,
    :avg_magic_damage_dealt_to_champions,
    :avg_magic_damage_taken,
    :avg_physical_damage_dealt,
    :avg_physical_damage_dealt_to_champions,
    :avg_physical_damage_taken,
    :avg_total_damage_dealt,
    :avg_total_damage_dealt_to_champions,
    :avg_total_damage_taken,
    :avg_total_heal,
    :avg_total_minions_killed,
    :avg_total_time_spent_dead,
    :avg_win
  ] ++ @required_fields

  schema "league_account_match_aggregates" do
    field :avg_assists, :float
    field :avg_baron_kills, :float
    field :avg_champ_experience, :float
    field :avg_champ_level, :float
    field :avg_damage_dealt_to_buildings, :float
    field :avg_damage_dealt_to_objectives, :float
    field :avg_damage_dealt_to_turrets, :float
    field :avg_damage_self_mitigated, :float
    field :avg_deaths, :float
    field :avg_gold_earned, :float
    field :avg_gold_spent, :float
    field :avg_kills, :float
    field :avg_largest_killing_spree, :float
    field :avg_largest_multi_kill, :float
    field :avg_magic_damage_dealt, :float
    field :avg_magic_damage_dealt_to_champions, :float
    field :avg_magic_damage_taken, :float
    field :avg_physical_damage_dealt, :float
    field :avg_physical_damage_dealt_to_champions, :float
    field :avg_physical_damage_taken, :float
    field :avg_total_damage_dealt, :float
    field :avg_total_damage_dealt_to_champions, :float
    field :avg_total_damage_taken, :float
    field :avg_total_heal, :float
    field :avg_total_minions_killed, :float
    field :avg_total_time_spent_dead, :float
    field :avg_win, :float
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
