defmodule LearnElixirFinal.PubSub.MatchAdded do
  alias LearnElixirFinalPg.League
  def notify_user_match_added(match, user_id) do
    Absinthe.Subscription.publish(
      LearnElixirFinalWeb.Endpoint,
      match,
      user_match_added: "user_match_added:#{user_id}"
    )
  end

  def notify_league_account_match_added(match, league_account_id) do
    Absinthe.Subscription.publish(
      LearnElixirFinalWeb.Endpoint,
      match,
      league_account_match_added: "league_account_match_added:#{league_account_id}"
    )
  end

  def notify_match_added(match_id) do
    with {:ok, match} <- League.find_league_match(%{id: match_id, preload: [:users, :league_accounts]}) do
      Enum.each(match.league_accounts, fn %{id: id} ->
        notify_league_account_match_added(match, id)
      end)

      Enum.each(match.users, fn %{id: id} ->
        notify_user_match_added(match, id)
      end)
    end
  end
end
