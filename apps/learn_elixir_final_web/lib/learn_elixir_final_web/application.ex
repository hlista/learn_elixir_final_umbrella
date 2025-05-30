defmodule LearnElixirFinalWeb.Application do
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
      {PrometheusTelemetry,
        exporter: [enabled?: true],
        metrics: [
          PrometheusTelemetry.Metrics.Cowboy.metrics(),
          PrometheusTelemetry.Metrics.Phoenix.metrics(),
          PrometheusTelemetry.Metrics.GraphQL.metrics(),
          PrometheusTelemetry.Metrics.VM.metrics()
        ]
      },
      # {DNSCluster, query: Application.get_env(:learn_elixir_final, :dns_cluster_query) || :ignore},
      # Start a worker by calling: LearnElixirFinalWeb.Worker.start_link(arg)
      # {LearnElixirFinalWeb.Worker, arg},
      # Start to serve requests, typically the last entry
      LearnElixirFinalWeb.Endpoint,
      {Phoenix.PubSub, name: LearnElixirFinalWeb.PubSub},
      {Absinthe.Subscription, LearnElixirFinalWeb.Endpoint},
      LearnElixirFinalWeb.Subscription.Tracker,
      LearnElixirFinalWeb.Subscription.Presence,
      LearnElixirFinalWeb.Subscription.Janitor,
      LearnElixirFinalWeb.Subscription.EventDispatcher
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LearnElixirFinalWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LearnElixirFinalWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
