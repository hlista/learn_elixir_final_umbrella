defmodule LearnElixirFinalWeb.Schema.Queries.User do
  @moduledoc false
  use Absinthe.Schema.Notation
  alias LearnElixirFinalWeb.Resolvers.UserResolver
  object :user_queries do
    field :fetch, :user do
      middleware LearnElixirFinalWeb.Middleware.Auth
      resolve &UserResolver.fetch/2
    end

    # field :search, list_of(:user) do

    # end
  end
end
