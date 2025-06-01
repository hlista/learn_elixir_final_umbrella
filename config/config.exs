# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

# Configure Mix tasks and generators
config :learn_elixir_final_pg,
  ecto_repos: [LearnElixirFinalPg.Repo]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :learn_elixir_final_pg, LearnElixirFinalPg.Mailer, adapter: Swoosh.Adapters.Local


config :ecto_shorts,
  repo: LearnElixirFinalPg.Repo,
  error_module: EctoShorts.Actions.Error

config :learn_elixir_final, Oban,
  repo: LearnElixirFinalPg.Repo,
  queues: [
    league_events_americas: 5,
    league_events_europe: 5,
    league_events_asia: 5,
    league_events_sea: 5,
    league_events: 5,
    league_match_aggregate: 5,
    league_listening: 5,
    league_match_participant_americas: 5,
    league_match_participant_europe: 5,
    league_match_participant_asia: 5,
    league_match_participant_sea: 5,
    league_match_participant: 5,
    league_match_found_americas: 5,
    league_match_found_europe: 5,
    league_match_found_asia: 5,
    league_match_found_sea: 5,
    league_match_found: 5,
  ],
  plugins: [Oban.Plugins.Pruner]

config :learn_elixir_final, :erpc_client, ErpcProxy

config :riot_client, :riot_api_key, "RGAPI-fd8e8601-33a9-4084-bc04-4d21405dd8d5"
config :riot_client, :http_client, RiotClient.RealHttpClient
# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :learn_elixir_final, LearnElixirFinal.Mailer, adapter: Swoosh.Adapters.Local

config :learn_elixir_final, ecto_repos: [LearnElixirFinalPg.Repo]

config :learn_elixir_final_web,
  ecto_repos: [LearnElixirFinalPg.Repo],
  generators: [context_app: :learn_elixir_final_pg]

# Configures the endpoint
config :learn_elixir_final_web, LearnElixirFinalWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: LearnElixirFinalWeb.ErrorHTML, json: LearnElixirFinalWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: LearnElixirFinalWeb.PubSub,
  live_view: [signing_salt: "qwn0vMaB"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  learn_elixir_final_web: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../apps/learn_elixir_final_web/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  learn_elixir_final_web: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../apps/learn_elixir_final_web/assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
