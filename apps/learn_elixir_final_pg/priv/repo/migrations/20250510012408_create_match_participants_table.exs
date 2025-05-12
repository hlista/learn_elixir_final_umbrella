defmodule LearnElixirFinalPg.Repo.Migrations.CreateMatchParticipantsTable do
  use Ecto.Migration

  def change do
    create table("match_participants") do
      add :puuid, :string
      add :assists, :integer
      add :baron_kills, :integer
      add :champ_experience, :integer
      add :champ_level, :integer
      add :champion_name, :string
      add :damage_dealt_to_buildings, :integer
      add :damage_dealt_to_objectives, :integer
      add :damage_dealt_to_turrets, :integer
      add :damage_self_mitigated, :integer
      add :deaths, :integer
      add :gold_earned, :integer
      add :gold_spent, :integer
      add :kills, :integer
      add :largest_killing_spree, :integer
      add :largest_multi_kill, :integer
      add :magic_damage_dealt, :integer
      add :magic_damage_dealt_to_champions, :integer
      add :magic_damage_taken, :integer
      add :physical_damage_dealt, :integer
      add :physical_damage_dealt_to_champions, :integer
      add :physical_damage_taken, :integer
      add :total_damage_dealt, :integer
      add :total_damage_dealt_to_champions, :integer
      add :total_damage_taken, :integer
      add :total_heal, :integer
      add :total_minions_killed, :integer
      add :total_time_spent_dead, :integer
      add :win, :boolean
      add :league_match_id, references("league_matches")
      timestamps()
    end
    create unique_index("match_participants", [:puuid, :league_match_id])
  end
end
