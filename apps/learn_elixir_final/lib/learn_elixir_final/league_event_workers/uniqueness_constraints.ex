defmodule LearnElixirFinal.LeagueEventWorkers.UniquenessConstraints do
  @user_match_listening_event_uniqueness [
    period: {2, :minutes},
    timestamp: :scheduled_at,
    keys: [:user_id, :event],
    fields: [:worker, :args]
  ]

  @league_account_match_listening_event_uniqueness [
    period: {2, :minutes},
    timestamp: :scheduled_at,
    keys: [:params, :event],
    fields: [:worker, :args]
  ]

  @league_match_found_event_uniqueness [
    period: {2, :minutes},
    timestamp: :scheduled_at,
    keys: [:match_id, :event],
    fields: [:worker, :args]
  ]

  @league_match_participant_found_event_uniqueness [
    period: {2, :minutes},
    timestamp: :scheduled_at,
    keys: [:participant, :event],
    fields: [:worker, :args]
  ]

  @aggregate_user_matches_event_uniqueness [
    period: {2, :minutes},
    timestamp: :scheduled_at,
    keys: [:user_id, :event],
    fields: [:worker, :args]
  ]

  @aggregate_league_account_matches_event_uniqueness [
    period: {2, :minutes},
    timestamp: :scheduled_at,
    keys: [:league_account_id, :event],
    fields: [:worker, :args]
  ]

  def user_match_listening_event, do: @user_match_listening_event_uniqueness
  def league_account_match_listening_event, do: @league_account_match_listening_event_uniqueness
  def league_match_found_event, do: @league_match_found_event_uniqueness
  def league_match_participant_found_event, do: @league_match_participant_found_event_uniqueness
  def aggregate_user_matches_event, do: @aggregate_user_matches_event_uniqueness
  def aggregate_league_account_matches_event, do: @aggregate_league_account_matches_event_uniqueness
end
