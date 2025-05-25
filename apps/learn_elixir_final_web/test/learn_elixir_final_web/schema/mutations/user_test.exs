defmodule LearnElixirFinalWeb.Schema.Mutations.UserTest do
  use LearnElixirFinalPg.DataCase
  alias LearnElixirFinalWeb.Schema
  import LearnElixirFinalPg.Factory

  @login_doc """
  mutation(
    $email: String!,
    $password: String!
  ){
    login(email: $email, password: $password)
  }
  """

  @logout_doc """
  mutation{
    logout {
      id
    }
  }
  """

  describe "login and logout" do
    setup do
      password = "password"
      user = insert(:user, hashed_password: Bcrypt.hash_pwd_salt(password))
      %{
        user: user,
        password: password
      }
    end
    test "login then logout", %{user: user, password: password} do
      assert {:ok, %{
        data: %{
          "login" => session_token
        }
      }} = Absinthe.run(
        @login_doc,
        Schema,
        variables: %{
          "email" => user.email,
          "password" => password
        },
        context: %{current_user: user}
      )

      user_id = Integer.to_string(user.id)

      assert {:ok, %{
        data: %{
          "logout" => %{
            "id" => ^user_id
          }
        }
      }} = Absinthe.run(
        @logout_doc,
        Schema,
        variables: %{},
        context: %{current_user: user, session: session_token}
      )
    end
    test "bad password", %{user: user} do
      {:ok, %{
        errors: [
          %{
            message: "Invalid email and password"
          }
        ]
      }} = Absinthe.run(
        @login_doc,
        Schema,
        variables: %{
          "email" => user.email,
          "password" => "badpassword"
        },
        context: %{current_user: user}
      )
    end
  end
end
