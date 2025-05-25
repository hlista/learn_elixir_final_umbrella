defmodule LearnElixirFinalWeb.Middleware.Auth do
  @moduledoc """
  Absinthe middleware to ensure a user is logged in before
  reaching a resolver
  """
  @behaviour Absinthe.Middleware

  @impl Absinthe.Middleware
  def call(res, opts \\ [])

  def call(%Absinthe.Resolution{context: %{current_user: user}} = res, _opts)
      when not is_nil(user) do
    res
  end

  def call(resolution, _opts) do
    resolution
    |> Absinthe.Resolution.put_result({:error, "unauthenticated"})
  end
end
