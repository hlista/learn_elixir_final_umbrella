defmodule LearnElixirFinalWeb.Resolvers.UserResolver do
  @moduledoc """
  Resolver functions for a user
  """
  alias LearnElixirFinalWeb.LearnElixirFinalProxy
  alias LearnElixirFinalWeb.Subscription.{
    Presence,
    Tracker
  }

  def login(%{email: email, password: password}, _) do
    user = LearnElixirFinalProxy.get_user_by_email_and_password(email, password)
    if user do
      token = LearnElixirFinalProxy.generate_user_session_token(user)
      {:ok, Base.url_encode64(token, padding: false)}
    else
      {:error, "Invalid email and password"}
    end
  end

  def logout(_, %{context: %{session: user_token, current_user: user}}) do
    LearnElixirFinalProxy.delete_user_session_token(user_token)
    {:ok, user}
  end

  def fetch(_, %{context: %{current_user: current_user}}) do
    {:ok, current_user}
  end

  def user_match_added_subscription(args, %{context: %{current_user: user}}) do
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

  def user_match_added_subscription(args, _) do
    {:error, "Please Login"}
  end
end
