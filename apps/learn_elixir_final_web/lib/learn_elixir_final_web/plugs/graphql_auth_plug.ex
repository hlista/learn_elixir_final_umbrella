defmodule LearnElixirFinalWeb.Plugs.GraphqlAuthPlug do
  @moduledoc """
  GraphQL plug to grab a users session token from the headder
  and insert the current user and session token into the context
  """
  import Plug.Conn
  alias LearnElixirFinalWeb.LearnElixirFinalProxy

  @behaviour Plug

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _opts \\ []) do
    with {:ok, session_token} <- get_session_token(conn),
         {:ok, session_binary} <- Base.url_decode64(session_token, padding: false),
         user <- LearnElixirFinalProxy.get_user_by_session_token(session_binary) do
      conn
      |> Absinthe.Plug.assign_context(:current_user, user)
      |> Absinthe.Plug.assign_context(:session, session_binary)
    else
      _ ->
        conn
    end
  end

  defp get_session_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> session_token] -> {:ok, session_token}
      _ -> {:error, "authorization required."}
    end
  end
end
