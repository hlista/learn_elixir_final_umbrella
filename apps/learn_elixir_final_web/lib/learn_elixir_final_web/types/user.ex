defmodule LearnElixirFinalWeb.Types.User do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  object :user do
    field :id, :id
    field :email, :string
    field :league_accounts, list_of(:league_account), resolve: dataloader(LearnElixirFinalWeb)
    field :match_aggregate, :match_aggregate, resolve: dataloader(LearnElixirFinalWeb)
  end
end
