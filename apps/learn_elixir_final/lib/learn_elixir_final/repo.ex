defmodule LearnElixirFinal.Repo do
  use Ecto.Repo,
    otp_app: :learn_elixir_final,
    adapter: Ecto.Adapters.Postgres
end
