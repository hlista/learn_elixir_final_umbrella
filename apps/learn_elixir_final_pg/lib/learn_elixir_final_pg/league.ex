defmodule LearnElixirFinalPg.League do
  alias EctoShorts.Actions
  alias LearnElixirFinalPg.League.{
    LeagueAccount,
    LeagueMatch,
    MatchParticipant,
    UserLeagueAccount
  }
  alias LearnElixirFinalPg.Repo

  ### League Accounts

  def all_league_accounts(params, opts \\ []) do
    Actions.all(LeagueAccount, params, opts)
  end

  def find_league_account(params, opts \\ []) do
    Actions.find(LeagueAccount, params, opts)
  end

  def create_league_account(params, opts \\ []) do
    Actions.create(LeagueAccount, params, opts)
  end

  def delete_league_account(id, opts \\ []) do
    Actions.delete(LeagueAccount, id, opts)
  end

  def find_and_update_league_account(find_params, update_params, opts \\ []) do
    Actions.find_and_update(LeagueAccount, find_params, update_params, opts)
  end

  def find_and_upsert_league_account(find_params, update_params, opts \\ []) do
    Actions.find_and_upsert(LeagueAccount, find_params, update_params, opts)
  end

  def find_or_create_league_account(params, opts \\ []) do
    Actions.find_or_create(LeagueAccount, params, opts)
  end

  def find_or_create_many_league_account(params_list, opts \\ []) do
    Actions.find_or_create_many(LeagueAccount, params_list, opts)
  end

  def update_league_account(id, update_params, opts \\ []) do
    Actions.update(LeagueAccount, id, update_params, opts)
  end

  ### League Matches

  def all_league_matchs(params, opts \\ []) do
    Actions.all(LeagueMatch, params, opts)
  end

  def find_league_match(params, opts \\ []) do
    Actions.find(LeagueMatch, params, opts)
  end

  def create_league_match(params, opts \\ []) do
    Actions.create(LeagueMatch, params, opts)
  end

  def delete_league_match(id, opts \\ []) do
    Actions.delete(LeagueMatch, id, opts)
  end

  def find_and_update_league_match(find_params, update_params, opts \\ []) do
    Actions.find_and_update(LeagueMatch, find_params, update_params, opts)
  end

  def find_and_upsert_league_match(find_params, update_params, opts \\ []) do
    Actions.find_and_upsert(LeagueMatch, find_params, update_params, opts)
  end

  def find_or_create_league_match(params, opts \\ []) do
    Actions.find_or_create(LeagueMatch, params, opts)
  end

  def find_or_create_many_league_match(params_list, opts \\ []) do
    Actions.find_or_create_many(LeagueMatch, params_list, opts)
  end

  def update_league_match(id, update_params, opts \\ []) do
    Actions.update(LeagueMatch, id, update_params, opts)
  end

  ### League Matches

  def all_match_participants(params, opts \\ []) do
    Actions.all(MatchParticipant, params, opts)
  end

  def find_match_participant(params, opts \\ []) do
    Actions.find(MatchParticipant, params, opts)
  end

  def create_match_participant(params, opts \\ []) do
    Actions.create(MatchParticipant, params, opts)
  end

  def delete_match_participant(id, opts \\ []) do
    Actions.delete(MatchParticipant, id, opts)
  end

  def find_and_update_match_participant(find_params, update_params, opts \\ []) do
    Actions.find_and_update(MatchParticipant, find_params, update_params, opts)
  end

  def find_and_upsert_match_participant(find_params, update_params, opts \\ []) do
    Actions.find_and_upsert(MatchParticipant, find_params, update_params, opts)
  end

  def find_or_create_match_participant(params, opts \\ []) do
    Actions.find_or_create(MatchParticipant, params, opts)
  end

  def find_or_create_many_match_participant(params_list, opts \\ []) do
    Actions.find_or_create_many(MatchParticipant, params_list, opts)
  end

  def update_match_participant(id, update_params, opts \\ []) do
    Actions.update(MatchParticipant, id, update_params, opts)
  end

  def preload_thirty_participants(user_or_league_account) do
    Repo.preload(user_or_league_account, [match_participants: MatchParticipant.last_thirty_query()])
  end
end
