defmodule LearnElixirFinal.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {
        Cluster.Supervisor,
        [Application.get_env(:libcluster, :topologies),
        [name: LearnElixirFinalWeb.ClusterSupervisor]]
      },
      # {DNSCluster, query: Application.get_env(:learn_elixir_final, :dns_cluster_query) || :ignore},
      # {Phoenix.PubSub, name: LearnElixirFinal.PubSub},
      LearnElixirFinalPg.Repo,
      # Start the Finch HTTP client for sending emails
      {Finch, name: LearnElixirFinal.Finch},
      {Oban, Application.fetch_env!(:learn_elixir_final, Oban)}
      # Start a worker by calling: LearnElixirFinal.Worker.start_link(arg)
      # {LearnElixirFinal.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: LearnElixirFinal.Supervisor)
  end
end
