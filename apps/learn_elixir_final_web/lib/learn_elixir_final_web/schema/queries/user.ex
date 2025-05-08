defmodule LearnElixerFinalWeb.Schema.Queries.User do
  use Absinthe.Schema.Notation

  object :user_queries do
    field :fetch, :user do
      arg :email, non_null(:string)
      arg :password, non_null(:string)
    end

    field :search, list_of(:user) do

    end
  end
end
