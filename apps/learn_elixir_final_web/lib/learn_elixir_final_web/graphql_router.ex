defmodule LearnElixirFinalWeb.GraphqlRouter do
  use Plug.Router

  plug :match
  plug :dispatch

  forward "/graphql",
    to: Absinthe.Plug,
    init_opts: [
      schema: LearnElixirFinalWeb.Schema
    ]

  forward "/graphiql",
    to: Absinthe.Plug.GraphiQL,
    init_opts: [
      schema: LearnElixirFinalWeb.Schema,
      interface: :simple
    ]
end
