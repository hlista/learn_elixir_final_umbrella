defmodule LearnElixirFinalWeb.Types.LeagueMatchParticipant do
  use Absinthe.Schema.Notation

  object :league_match_participant do
    field :id, :id
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
    field :game_end_timestamp, :datetime
  end
end
