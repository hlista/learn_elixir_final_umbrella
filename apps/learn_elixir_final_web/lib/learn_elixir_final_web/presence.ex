defmodule LearnElixirFinalWeb.Presence do
  use Phoenix.Presence,
    otp_app: :learn_elixir_final,
    pubsub_server: LearnElixirFinal.PubSub


end
