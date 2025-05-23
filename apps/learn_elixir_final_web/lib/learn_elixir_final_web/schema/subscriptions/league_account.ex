defmodule LearnElixirFinalWeb.Schema.Subscriptions.LeagueAccount do
  use Absinthe.Schema.Notation

  object :league_account_subscriptions do
    field :league_account_match_added, :league_match do
      arg :puuid, :string
      arg :league_account_id, :id
      middleware LearnElixirFinalWeb.Middleware.Auth
      config
        fn %{puuid: puuid}, %{context: %{current_user: user}} ->
          topic = "league_account_match_added:puuid:#{puuid}"
          LearnElixirFinalWeb.Subscription.Tracker.track(topic)
          LearnElixirFinalWeb.Subscription.Presence.track(
            self(),
            topic,
            user.id,
            %{joined_at: System.system_time(:second)}
          )
          {:ok, topic: topic}
        end
        fn %{league_account_id: league_account_id}, %{context: %{current_user: user}} ->
          topic = "league_account_match_added:league_account_id:#{league_account_id}"
          LearnElixirFinalWeb.Subscription.Tracker.track(topic)
          LearnElixirFinalWeb.Subscription.Presence.track(
            self(),
            topic,
            user.id,
            %{joined_at: System.system_time(:second)}
          )
          {:ok, topic: topic}
        end
        fn _ ->
          {:error, ErrorMessage.bad_request("Provide a league_account_id or puuid")}
        end
    end
  end
end
