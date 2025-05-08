defmodule LearnElixerFinalWeb.Schema.Mutations.User do
  use Absinthe.Schema.Notation

  object :user_mutations do
    field :login, :user do
      arg :email, non_null(:string)
      arg :password, non_null(:string)
    end

    field :logout, :user do

    end

    field :sign_up, :user do
      arg :email, non_null(:string)
      arg :password, non_null(:string)
    end
  end
end
