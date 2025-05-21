defmodule RiotClient.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Finch, name: RiotClient.Finch},
      RiotClient.HttpQueue,
      # RiotClient.HttpQueue.BackoffLimiter,
      %{
        id: :americas_backoff_limiter,
        start: {
          RiotClient.HttpQueue.BackoffLimiter,
          :start_link,
          [[
            name: :americas_backoff_limiter
          ]]
        }
      },%{
        id: :asia_backoff_limiter,
        start: {
          RiotClient.HttpQueue.BackoffLimiter,
          :start_link,
          [[
            name: :asia_backoff_limiter
          ]]
        }
      },%{
        id: :europe_backoff_limiter,
        start: {
          RiotClient.HttpQueue.BackoffLimiter,
          :start_link,
          [[
            name: :europe_backoff_limiter
          ]]
        }
      },%{
        id: :sea_backoff_limiter,
        start: {
          RiotClient.HttpQueue.BackoffLimiter,
          :start_link,
          [[
            name: :sea_backoff_limiter
          ]]
        }
      }
      # Start a worker by calling: LearnElixirFinal.Worker.start_link(arg)
      # {LearnElixirFinal.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: RiotClient.Supervisor)
  end
end
