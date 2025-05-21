defmodule LearnElixirFinalWeb.Schema.Mutations.User do
  use Absinthe.Schema.Notation
  alias LearnElixirFinalWeb.Resolvers.UserResolver
  object :user_mutations do
    field :login, :string do
      arg :email, non_null(:string)
      arg :password, non_null(:string)
      resolve &UserResolver.login/2
    end

    field :logout, :user do
      resolve &UserResolver.logout/2
    end
  end
end
