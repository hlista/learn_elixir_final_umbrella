defmodule LearnElixirFinalWeb.GraphqlRouter do
  use LearnElixirFinalWeb, :router

  forward "/graphql", Absinthe.Plug,
    schema: LearnElixirFinalWeb.Schema

  forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: LearnElixirFinalWeb.Schema,
      socket: LearnElixirFinalWeb.UserSocket,
      interface: :playground
end
