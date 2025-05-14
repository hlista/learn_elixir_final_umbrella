defmodule LearnElixirFinal.LeagueAggregate do
  import Ecto.Query
  alias LearnElixirFinalPg.Repo

  def aggregate_league_account(league_account_id) do
    participant_query = from p in LearnElixirFinalPg.League.MatchParticipant, limit: 30, order_by: p.game_end_timestamp
    LearnElixirFinalPg.League.LeagueAccount
    |> Repo.get(league_account_id)
    |> Repo.preload([match_participants: participant_query])
  end

  def aggregate_user(user_id) do
    participant_query = from p in LearnElixirFinalPg.League.MatchParticipant, limit: 30, order_by: p.game_end_timestamp
    LearnElixirFinalPg.Auth.User
    |> Repo.get(user_id)
    |> Repo.preload([match_participants: participant_query])
  end
end
