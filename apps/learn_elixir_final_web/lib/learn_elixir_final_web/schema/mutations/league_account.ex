defmodule LearnElixirFinalWeb.Schema.Mutations.LeagueAccount do
  use Absinthe.Schema.Notation

  object :league_account_mutations do
    field :add_summoner, :league_account do
      arg :region, non_null(:string)
      arg :game_name, non_null(:string)
      arg :tag_line, non_null(:string)
    end

    field :remove_summoner, :league_account do
      arg :puuid, non_null(:string)
    end
  end
end
