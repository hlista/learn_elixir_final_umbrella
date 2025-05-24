defmodule LearnElixirFinalPg.Factory do
  use ExMachina.Ecto, repo: LearnElixirFinalPg.Repo
  alias LearnElixirFinalPg.Accounts.User
  alias LearnElixirFinalPg.League.{
    #LeagueAccountMatchAggregate,
    LeagueAccount,
    LeagueMatch,
    MatchParticipant,
    #UserLeagueAccount,
    #UserMatchAggregate
  }

  def user_factory do
    %User{
      email: sequence(:email, &"email-#{&1}@example.com"),
      hashed_password: sequence("password")
    }
  end

  def league_account_factory do
    %LeagueAccount{
      puuid: sequence("puuid"),
      tag_line: sequence("tagline"),
      game_name: sequence("gamename"),
      region: sequence(:region, ["na", "br", "lan", "las", "kr", "jp", "eune", "euw", "me", "tr", "ru", "oce", "sg", "tw", "vn"]),
      match_region: sequence(:match_region, ["americas", "asia", "sea", "europe"]),
      match_offset: 0
    }
  end

  def match_participant_factory do
    %MatchParticipant{
      puuid: sequence("puuid"),
      assists: sequence(:league_stat, Enum.to_list(1..5)),
      baron_kills: sequence(:league_stat, Enum.to_list(1..5)),
      champ_experience: sequence(:league_stat, Enum.to_list(1..5)),
      champ_level: sequence(:league_stat, Enum.to_list(1..5)),
      champion_name: sequence("champion"),
      damage_dealt_to_buildings: sequence(:league_stat, Enum.to_list(1..5)),
      damage_dealt_to_objectives: sequence(:league_stat, Enum.to_list(1..5)),
      damage_dealt_to_turrets: sequence(:league_stat, Enum.to_list(1..5)),
      damage_self_mitigated: sequence(:league_stat, Enum.to_list(1..5)),
      deaths: sequence(:league_stat, Enum.to_list(1..5)),
      gold_earned: sequence(:league_stat, Enum.to_list(1..5)),
      gold_spent: sequence(:league_stat, Enum.to_list(1..5)),
      kills: sequence(:league_stat, Enum.to_list(1..5)),
      largest_killing_spree: sequence(:league_stat, Enum.to_list(1..5)),
      largest_multi_kill: sequence(:league_stat, Enum.to_list(1..5)),
      magic_damage_dealt: sequence(:league_stat, Enum.to_list(1..5)),
      magic_damage_dealt_to_champions: sequence(:league_stat, Enum.to_list(1..5)),
      magic_damage_taken: sequence(:league_stat, Enum.to_list(1..5)),
      physical_damage_dealt: sequence(:league_stat, Enum.to_list(1..5)),
      physical_damage_dealt_to_champions: sequence(:league_stat, Enum.to_list(1..5)),
      physical_damage_taken: sequence(:league_stat, Enum.to_list(1..5)),
      total_damage_dealt: sequence(:league_stat, Enum.to_list(1..5)),
      total_damage_dealt_to_champions: sequence(:league_stat, Enum.to_list(1..5)),
      total_damage_taken: sequence(:league_stat, Enum.to_list(1..5)),
      total_heal: sequence(:league_stat, Enum.to_list(1..5)),
      total_minions_killed: sequence(:league_stat, Enum.to_list(1..5)),
      total_time_spent_dead: sequence(:league_stat, Enum.to_list(1..5)),
      win: sequence(:win, [true, false]),
      game_end_timestamp: DateTime.utc_now(),
    }
  end

  def league_match_factory do
    %LeagueMatch{
      match_id: sequence("match_"),
      region: sequence(:match_region, ["americas", "asia", "sea", "europe"]),
      game_duration: 1000,
      game_end_timestamp: DateTime.utc_now(),
      game_id: 1000,
      game_name: sequence("game_")
    }
  end
end
