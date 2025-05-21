defmodule LearnElixirFinalWeb.Schema.Subscriptions.User do
  use Absinthe.Schema.Notation

  object :user_subscriptions do
    field :user_match_added, :league_match do
      arg :user_id, non_null(:id)
      config fn args, %{context: %{current_user: user}} ->
        topic = "user_match_added:#{args.user_id}"
        LearnElixirFinalWeb.Subscription.Tracker.track(topic)
        LearnElixirFinalWeb.Subscription.Presence.track(
          self(),  # the process (in Absinthe context, the socket's process)
          topic,
          user.id,
          %{joined_at: System.system_time(:second)}
        )
        {:ok, topic: topic}
      end
    end
  end
end
