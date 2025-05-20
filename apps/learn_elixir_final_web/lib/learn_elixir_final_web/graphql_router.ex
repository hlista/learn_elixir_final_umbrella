defmodule LearnElixirFinalWeb.GraphqlRouter do
  use LearnElixirFinalWeb, :router

  forward "/graphql", Absinthe.Plug,
    schema: LearnElixirFinalWeb.Schema

  forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: LearnElixirFinalWeb.Schema,
      interface: :playground
end
