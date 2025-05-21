defmodule LearnElixirFinalWeb.Types.LeagueMatch do
  use Absinthe.Schema.Notation

#  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  object :league_match do
    field :id, :id
    field :match_id, :string
    field :region, :string
    field :game_duration, :integer
    field :game_end_timestamp, :datetime
    field :game_id, :integer
    field :game_name, :string
    field :participants, list_of(:string)
    # field :league_accounts, list_of(:league_account)
  end
end
