defmodule LearnElixirFinalWeb.Schema.Mutations.User do
  @moduledoc false
  use Absinthe.Schema.Notation
  alias LearnElixirFinalWeb.Resolvers.UserResolver
  object :user_mutations do
    field :login, :string do
      arg :email, non_null(:string)
      arg :password, non_null(:string)
      resolve &UserResolver.login/2
    end

    field :logout, :user do
      middleware LearnElixirFinalWeb.Middleware.Auth
      resolve &UserResolver.logout/2
    end
  end
end
