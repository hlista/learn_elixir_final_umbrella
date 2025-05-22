defmodule LearnElixirFinalWeb.Schema.Mutations.LeagueAccount do
  use Absinthe.Schema.Notation
  alias LearnElixirFinalWeb.Resolvers.LeagueAccountResolver
  object :league_account_mutations do
    field :add_summoner_by_game_name_tag_line, :league_account do
      arg :game_name, non_null(:string)
      arg :tag_line, non_null(:string)
      resolve &LeagueAccountResolver.add_summoner_by_game_name_tag_line/2
    end

    field :add_summoner_by_puuid, :league_account do
      arg :puuid, non_null(:string)
      resolve &LeagueAccountResolver.add_summoner_by_puuid/2
    end

    field :remove_summoner, :league_account do
      arg :puuid, non_null(:string)
      resolve &LeagueAccountResolver.remove_summoner/2
    end
  end
end
