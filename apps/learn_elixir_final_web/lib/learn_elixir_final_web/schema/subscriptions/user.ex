defmodule LearnElixirFinalWeb.Schema.Subscriptions.User do
  use Absinthe.Schema.Notation
  alias LearnElixirFinalWeb.Resolvers.UserResolver

  object :user_subscriptions do
    field :user_match_added, :match_aggregate do
      arg :user_id, non_null(:id)
      config fn args, info ->
        UserResolver.user_match_added_subscription(args, info)
      end
    end
  end
end
