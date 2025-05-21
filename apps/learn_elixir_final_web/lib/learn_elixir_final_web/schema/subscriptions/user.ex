defmodule LearnElixirFinalWeb.Schema.Subscriptions.User do
  use Absinthe.Schema.Notation

  object :user_subscriptions do
    field :user_match_added, :league_match do
      arg :user_id, non_null(:id)
      config fn args, _ ->
        {:ok, topic: "user_match_added:" <> args.user_id}
      end
    end
  end
end
