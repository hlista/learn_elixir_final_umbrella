defmodule LearnElixirFinalWeb.Resolvers.UserResolver do
  alias LearnElixirFinalPg.Accounts
  def login(%{email: email, password: password}, _) do
    user = Accounts.get_user_by_email_and_password(email, password)
    if user do
      token = Accounts.generate_user_session_token(user)
      {:ok, Base.url_encode64(token, padding: false)}
    else
      {:error, "Invalid email and password"}
    end
  end

  def logout(_, %{current_user: current_user}) do

  end

  def fetch(_, %{context: %{current_user: current_user}}) do
    {:ok, current_user}
  end
end
