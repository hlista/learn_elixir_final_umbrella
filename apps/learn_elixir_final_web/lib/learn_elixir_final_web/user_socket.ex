defmodule LearnElixirFinalWeb.UserSocket do
  use Phoenix.Socket
  use Absinthe.Phoenix.Socket,
    schema: LearnElixirFinalWeb.Schema
  alias LearnElixirFinalPg.Accounts

  def connect(params, socket) do
    with {:ok, session_token} <- get_session_token(params),
         {:ok, session_binary} <- Base.url_decode64(session_token, padding: false),
         {:ok, user} <- get_user_by_session_token(session_binary) do
      context = %{
        current_user: user
      }
      socket
      |> Phoenix.Socket.assign(context)
      |> Absinthe.Phoenix.Socket.put_options(context: context)
      |> then(&{:ok, &1})
    end
  end

  defp get_session_token(%{"authorization" => "Bearer " <> session_token}) do
    {:ok, session_token}
  end

  defp get_session_token(_) do
    :error
  end

  defp get_user_by_session_token(session_binary) do
    case Accounts.get_user_by_session_token(session_binary) do
      nil -> :error
      user -> {:ok, user}
    end
  end

  def id(socket), do: "user_socket:#{socket.assigns.current_user.id}"
end
