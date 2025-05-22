defmodule LearnElixirFinalWeb.LearnElixirFinalProxy do
  @current_env Mix.env()
  def call_on_random_node(function, params) do
    if @current_env === :test do
      apply(LearnElixirFinal, function, params)
    else
      :rpc.call(get_random_node(), LearnElixirFinal, function, params)
    end
  end

  def get_random_node() do
    Node.list()
    |> Enum.filter(&(to_string(&1) =~ "learn_elixir_final@"))
    |> Enum.random()
  end

  ### Deliver Emails
  def deliver_user_confirmation_instructions(user, url) do
    call_on_random_node(:deliver_user_confirmation_instructions, [user, url])
  end

  def deliver_user_update_email_instructions(user, email, url) do
    call_on_random_node(:deliver_user_update_email_instructions, [user, email, url])
  end

  def deliver_user_reset_password_instructions(user, url) do
    call_on_random_node(:deliver_user_reset_password_instructions, [user, url])
  end


  ### User Email
  def get_user_by_email(email) do
    call_on_random_node(:get_user_by_email, [email])
  end

  def change_user_email(user, params \\ %{}) do
    call_on_random_node(:change_user_email, [user, params])
  end

  def update_user_email(user, token) do
    call_on_random_node(:update_user_email, [user, token])
  end

  def get_user_by_email_and_password(email, password) do
    call_on_random_node(:get_user_by_email_and_password, [email, password])
  end

  def apply_user_email(user, password, user_params) do
    call_on_random_node(:apply_user_email, [user, password, user_params])
  end


  ### User Password
  def update_user_password(user, password, user_params) do
    call_on_random_node(:update_user_password, [user, password, user_params])
  end

  def change_user_password(user, params \\ %{}) do
    call_on_random_node(:change_user_password, [user, params])
  end

  def reset_user_password(user, user_params) do
    call_on_random_node(:reset_user_password, [user, user_params])
  end

  def get_user_by_reset_password_token(token) do
    call_on_random_node(:get_user_by_reset_password_token, [token])
  end


  ### User Registration
  def register_user(user_params) do
    call_on_random_node(:register_user, [user_params])
  end

  def confirm_user(token) do
    call_on_random_node(:confirm_user, [token])
  end

  def change_user_registration(user, user_params \\ %{}) do
    call_on_random_node(:change_user_registration, [user, user_params])
  end


  ### User Session Token
  def generate_user_session_token(user) do
    call_on_random_node(:generate_user_session_token, [user])
  end

  def delete_user_session_token(user_token) do
    call_on_random_node(:delete_user_session_token, [user_token])
  end

  def get_user_by_session_token(session_binary) do
    call_on_random_node(:get_user_by_session_token, [session_binary])
  end

end
