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
      RiotClient.HttpQueue.BackoffLimiter,
      RiotClient.HttpQueue.BackoffLimiterTwo,
      %{
        id: :americas_second_limiter,
        start: {
          RiotClient.TokenBucketLimiter,
          :start_link,
          [[
            name: :americas_second_limiter,
            rate_limit: 20,
            max_tokens: 20,
            interval: 1_000
          ]]
        }
      },
      %{
        id: :americas_minute_limiter,
        start: {
          RiotClient.TokenBucketLimiter,
          :start_link,
          [[
            name: :americas_minute_limiter,
            rate_limit: 100,
            max_tokens: 100,
            interval: 120_000
          ]]
        }
      },
      %{
        id: :asia_second_limiter,
        start: {
          RiotClient.TokenBucketLimiter,
          :start_link,
          [[
            name: :asia_second_limiter,
            rate_limit: 20,
            max_tokens: 20,
            interval: 1_000
          ]]
        }
      },
      %{
        id: :asia_minute_limiter,
        start: {
          RiotClient.TokenBucketLimiter,
          :start_link,
          [[
            name: :asia_minute_limiter,
            rate_limit: 100,
            max_tokens: 100,
            interval: 120_000
          ]]
        }
      },
      %{
        id: :europe_second_limiter,
        start: {
          RiotClient.TokenBucketLimiter,
          :start_link,
          [[
            name: :europe_second_limiter,
            rate_limit: 20,
            max_tokens: 18,
            interval: 1_000
          ]]
        }
      },
      %{
        id: :europe_minute_limiter,
        start: {
          RiotClient.TokenBucketLimiter,
          :start_link,
          [[
            name: :europe_minute_limiter,
            rate_limit: 100,
            max_tokens: 90,
            interval: 120_000
          ]]
        }
      },
      %{
        id: :sea_second_limiter,
        start: {
          RiotClient.TokenBucketLimiter,
          :start_link,
          [[
            name: :sea_second_limiter,
            rate_limit: 20,
            max_tokens: 20,
            interval: 1_000
          ]]
        }
      },
      %{
        id: :sea_minute_limiter,
        start: {
          RiotClient.TokenBucketLimiter,
          :start_link,
          [[
            name: :sea_minute_limiter,
            rate_limit: 100,
            max_tokens: 100,
            interval: 120_000
          ]]
        }
      },
      # Start a worker by calling: LearnElixirFinal.Worker.start_link(arg)
      # {LearnElixirFinal.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: RiotClient.Supervisor)
  end
end
