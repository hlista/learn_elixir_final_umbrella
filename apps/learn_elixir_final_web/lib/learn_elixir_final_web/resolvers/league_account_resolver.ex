defmodule LearnElixirFinalWeb.Resolvers.LeagueAccountResolver do
  @moduledoc """
  Resolver functions for a league account
  """
  alias LearnElixirFinalWeb.LearnElixirFinalProxy
  alias LearnElixirFinalWeb.Subscription.{
    Presence,
    Tracker
  }

  def add_summoner_by_game_name_tag_line(%{
    tag_line: tag_line,
    game_name: game_name
  }, %{context: %{current_user: current_user}}) do
    LearnElixirFinalProxy.add_user_league_account_by_game_name_tag_line(current_user.id, game_name, tag_line)
  end

  def add_summoner_by_puuid(%{
    puuid: puuid
  }, %{context: %{current_user: current_user}}) do
    LearnElixirFinalProxy.add_user_league_account_by_puuid(current_user.id, puuid)
  end

  def remove_summoner(%{
    league_account_id: league_account_id
  }, %{context: %{current_user: current_user}}) do
    LearnElixirFinalProxy.remove_user_league_account(current_user.id, league_account_id)
  end

  def league_account_match_added_subscription(%{puuid: puuid}, %{context: %{current_user: user}}) do
    topic = "league_account_match_added:puuid:#{puuid}"
    Tracker.track(topic)
    Presence.track(
      self(),
      topic,
      user.id,
      %{joined_at: System.system_time(:second)}
    )
    {:ok, topic: topic}
  end

  def league_account_match_added_subscription(%{league_account_id: league_account_id}, %{context: %{current_user: user}}) do
    topic = "league_account_match_added:league_account_id:#{league_account_id}"
    Tracker.track(topic)
    Presence.track(
      self(),
      topic,
      user.id,
      %{joined_at: System.system_time(:second)}
    )
    {:ok, topic: topic}
  end

  def league_account_match_added_subscription(_, _) do
    {:error, ErrorMessage.bad_request("Provide a league_account_id or puuid")}
  end
end
