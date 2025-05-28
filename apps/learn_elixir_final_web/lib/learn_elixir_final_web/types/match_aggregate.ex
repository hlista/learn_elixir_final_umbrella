defmodule LearnElixirFinalWeb.Types.MatchAggregate do
  use Absinthe.Schema.Notation

  object :match_aggregate do
    field :id, :id
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
  end
end
