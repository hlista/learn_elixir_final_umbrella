defmodule LearnElixirFinalWeb.Schema.Subscriptions.LeagueAccount do
  use Absinthe.Schema.Notation

  object :league_account_subscriptions do
    field :league_account_match_added, :league_match do
      arg :puuid, non_null(:string)
      config fn args, _ ->
        {:ok, topic: "league_account_match_added:" <> args.puuid}
      end
    end
  end
end
