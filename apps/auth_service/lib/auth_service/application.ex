defmodule AuthService.Application do
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
      AuthService.Telemetry,
      LearnElixirFinalPg.Repo,
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: AuthService.Supervisor)
  end
end
