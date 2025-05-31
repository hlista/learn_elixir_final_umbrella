defmodule LearnElixirFinalWeb.Schema.Subscriptions.LeagueAccount do
  use Absinthe.Schema.Notation
  alias LearnElixirFinalWeb.Resolvers.LeagueAccountResolver

  object :league_account_subscriptions do
    field :league_account_match_added, :match_aggregate do
      arg :puuid, :string
      arg :league_account_id, :id
      config fn args, info ->
        LeagueAccountResolver.league_account_match_added_subscription(args, info)
      end
    end
  end
end
