defmodule LearnElixirFinalWeb.Schema do
  use Absinthe.Schema
  import_types Absinthe.Type.Custom
  import_types LearnElixirFinalWeb.Types.{
    User,
    LeagueAccount,
    LeagueMatch,
    LeagueMatchParticipant,
    MatchAggregate
  }
  import_types LearnElixirFinalWeb.Schema.Queries.User
  import_types LearnElixirFinalWeb.Schema.Mutations.{
    LeagueAccount,
    User
  }
  import_types LearnElixirFinalWeb.Schema.Subscriptions.User
  query do
    import_fields :user_queries
  end
  mutation do
    import_fields :user_mutations
    import_fields :league_account_mutations
  end
  subscription do
    import_fields :user_subscriptions
  end
end
