defmodule LearnElixirFinalWeb.Schema.Subscriptions.User do
  use Absinthe.Schema.Notation
  alias LearnElixirFinalWeb.Subscription.{
    Presence,
    Tracker
  }

  object :user_subscriptions do
    field :user_match_added, :league_match do
      arg :user_id, non_null(:id)
      middleware LearnElixirFinalWeb.Middleware.Auth
      config fn args, %{context: %{current_user: user}} ->
        topic = "user_match_added:#{args.user_id}"
        Tracker.track(topic)
        Presence.track(
          self(),
          topic,
          user.id,
          %{joined_at: System.system_time(:second)}
        )
        {:ok, topic: topic}
      end
    end
  end
end
