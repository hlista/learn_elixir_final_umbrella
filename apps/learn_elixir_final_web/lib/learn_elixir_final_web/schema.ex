defmodule LearnElixirFinalWeb.Schema do
  use Absinthe.Schema
  import_types LearnElixerFinalWeb.Types.User
  import_types LearnElixerFinalWeb.Schema.Queries.User
  query do
    import_fields :user_queries
  end
end
