defmodule LearnElixirFinalWeb.Types.LeagueAccount do
  use Absinthe.Schema.Notation

  object :league_account do
    field :id, :id
    field :puuid, :string
    field :tag_line, :string
    field :game_name, :string
    field :region, :string
    field :match_region, :string
  end
end
