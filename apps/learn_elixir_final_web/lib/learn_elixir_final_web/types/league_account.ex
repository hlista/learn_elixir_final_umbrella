defmodule LearnElixerFinalWeb.Types.LeagueAccount do
  use Absinthe.Schema.Notation

  object :league_account do
    field :region, :string
    field :tag_line, :string
    field :game_name, :string
    field :puuid, :string
  end
end
