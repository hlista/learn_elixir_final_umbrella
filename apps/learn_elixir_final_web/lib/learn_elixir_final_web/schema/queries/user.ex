defmodule LearnElixerFinalWeb.Schema.Queries.User do
  use Absinthe.Schema.Notation

  object :user_queries do
    field :fetch, :user do

    end

    field :search, list_of(:user) do

    end
  end
end
