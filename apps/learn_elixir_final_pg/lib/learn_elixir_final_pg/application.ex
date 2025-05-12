defmodule LearnElixirFinalPg.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LearnElixirFinalPg.Repo,
      {DNSCluster, query: Application.get_env(:learn_elixir_final_pg, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: LearnElixirFinalPg.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: LearnElixirFinalPg.Finch}
      # Start a worker by calling: LearnElixirFinalPg.Worker.start_link(arg)
      # {LearnElixirFinalPg.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: LearnElixirFinalPg.Supervisor)
  end
end
