defmodule LearnElixirFinalWeb.Types.LeagueAccount do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  object :league_account do
    field :id, :id
    field :puuid, :string
    field :tag_line, :string
    field :game_name, :string
    field :region, :string
    field :match_region, :string
    field :match_aggregate, :match_aggregate, resolve: dataloader(LearnElixirFinalWeb)
  end
end
