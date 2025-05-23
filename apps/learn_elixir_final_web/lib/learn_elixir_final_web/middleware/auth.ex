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

  def call(%Absinthe.Resolution{} = res, _opts) do
    Absinthe.Resolution.put_result(
      res,
      {:error, ErrorMessage.unauthorized("please login to continue.")}
    )
  end
end
