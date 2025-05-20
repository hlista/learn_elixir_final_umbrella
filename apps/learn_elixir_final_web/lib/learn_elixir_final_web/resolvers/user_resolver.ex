defmodule LearnElixirFinalWeb.Resolvers.UserResolver do
  def login(_, _) do

  end

  def logout(_, _) do

  end

  def fetch(%{current_user: current_user}, _) do
    {:ok, current_user}
  end
end
