defmodule LearnElixirFinalPg.Repo.Migrations.AddLeagueAccountMatchAggregatesTable do
  use Ecto.Migration

  def change do
    create table("league_account_match_aggregates") do
      add :avg_assists, :float, default: 0.0
      add :avg_baron_kills, :float, default: 0.0
      add :avg_champ_experience, :float, default: 0.0
      add :avg_champ_level, :float, default: 0.0
      add :avg_damage_dealt_to_buildings, :float, default: 0.0
      add :avg_damage_dealt_to_objectives, :float, default: 0.0
      add :avg_damage_dealt_to_turrets, :float, default: 0.0
      add :avg_damage_self_mitigated, :float, default: 0.0
      add :avg_deaths, :float, default: 0.0
      add :avg_gold_earned, :float, default: 0.0
      add :avg_gold_spent, :float, default: 0.0
      add :avg_kills, :float, default: 0.0
      add :avg_largest_killing_spree, :float, default: 0.0
      add :avg_largest_multi_kill, :float, default: 0.0
      add :avg_magic_damage_dealt, :float, default: 0.0
      add :avg_magic_damage_dealt_to_champions, :float, default: 0.0
      add :avg_magic_damage_taken, :float, default: 0.0
      add :avg_physical_damage_dealt, :float, default: 0.0
      add :avg_physical_damage_dealt_to_champions, :float, default: 0.0
      add :avg_physical_damage_taken, :float, default: 0.0
      add :avg_total_damage_dealt, :float, default: 0.0
      add :avg_total_damage_dealt_to_champions, :float, default: 0.0
      add :avg_total_damage_taken, :float, default: 0.0
      add :avg_total_heal, :float, default: 0.0
      add :avg_total_minions_killed, :float, default: 0.0
      add :avg_total_time_spent_dead, :float, default: 0.0
      add :avg_win, :float, default: 0.0
      add :league_account_id, references("league_accounts")
      timestamps()
    end
    create unique_index("league_account_match_aggregates", :league_account_id)
  end
end
