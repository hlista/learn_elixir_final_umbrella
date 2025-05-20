defmodule LearnElixirFinalWeb.Schema do
  use Absinthe.Schema
  import_types LearnElixerFinalWeb.Types.User
  import_types LearnElixerFinalWeb.Schema.Queries.User
  import_types LearnElixerFinalWeb.Schema.Mutations.User
  query do
    import_fields :user_queries
  end
  mutation do
    import_fields :user_mutations
  end
end
