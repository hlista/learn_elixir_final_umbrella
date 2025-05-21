defmodule LearnElixirFinalWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LearnElixirFinalWeb.Telemetry,
      # Start a worker by calling: LearnElixirFinalWeb.Worker.start_link(arg)
      # {LearnElixirFinalWeb.Worker, arg},
      # Start to serve requests, typically the last entry
      LearnElixirFinalWeb.Presence,
      LearnElixirFinalWeb.Endpoint,
      {Absinthe.Subscription, LearnElixirFinalWeb.Endpoint},
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
