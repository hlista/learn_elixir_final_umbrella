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

  def context(ctx) do
    erpc_call = &ErpcProxy.call_on_random_node(
      %ErpcProxy{node_name: "learn_elixir_final@"}, &1, &2, &3
    )
    source = LearnElixirFinalWeb.Dataloader.Erpc.new(LearnElixirFinalPg.Repo, erpc_call)
    dataloader = Dataloader.add_source(Dataloader.new(), LearnElixirFinalWeb, source)

    Map.put(ctx, :loader, dataloader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
