defmodule LearnElixirFinalWeb.Schema.Queries.UserTest do
  use LearnElixirFinalPg.DataCase
  alias LearnElixirFinalWeb.Schema
  import LearnElixirFinalPg.Factory

  @fetch_doc """
  query{
    fetch {
      id
      email
      league_accounts{
        id
      }
    }
  }
  """

  describe "fetch user" do
    setup do
      user = insert(:user, league_accounts: [build(:league_account)])
      %{
        user: user
      }
    end
    test "user", %{user: %{id: id, email: email} = user} do
      id = Integer.to_string(id)
      [%{id: league_account_id} | _] = user.league_accounts
      league_account_id = Integer.to_string(league_account_id)
      assert {:ok,
      %{
        data: %{
          "fetch" => %{
            "id" => ^id,
            "email" => ^email,
            "league_accounts" => [%{
              "id" => ^league_account_id
            }]
          }
        }
      }} = Absinthe.run(
        @fetch_doc,
        Schema,
        variables: %{},
        context: %{current_user: user}
      )
    end

    test "not logged in", _ do
      assert {:ok, %{
        errors: [
          %{
            message: "unauthenticated"
          }
        ]
      }} = Absinthe.run(
        @fetch_doc,
        Schema,
        variables: %{},
        context: %{}
      )
    end
  end
end
