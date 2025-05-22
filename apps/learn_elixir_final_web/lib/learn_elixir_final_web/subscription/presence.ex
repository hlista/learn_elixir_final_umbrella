defmodule LearnElixirFinalWeb.Subscription.Presence do
  use Phoenix.Presence,
    otp_app: :learn_elixir_final_web,
    pubsub_server: LearnElixirFinalWeb.PubSub
end
