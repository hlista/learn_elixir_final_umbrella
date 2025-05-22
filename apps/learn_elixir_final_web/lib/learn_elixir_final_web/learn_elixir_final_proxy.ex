defmodule LearnElixirFinalWeb.LearnElixirFinalProxy do
  alias LearnElixirFinalWeb.ErpcProxy

  @erpc_proxy %LearnElixirFinalWeb.ErpcProxy{
    node_name: "learn_elixir_final@"
  }

  @module LearnElixirFinal

  def add_user_league_account_by_game_name_tag_line(user_id, game_name, tag_line) do
    ErpcProxy.call_on_random_node(
      @erpc_proxy,
      @module,
      :add_user_league_account_by_game_name_tag_line,
      [user_id, game_name, tag_line]
    )
  end

  def add_user_league_account_by_puuid(user_id, puuid) do
    ErpcProxy.call_on_random_node(
      @erpc_proxy,
      @module,
      :add_user_league_account_by_puuid,
      [user_id, puuid]
    )
  end

  def remove_user_league_account(user_id, puuid) do
    ErpcProxy.call_on_random_node(
      @erpc_proxy,
      @module,
      :remove_user_league_account,
      [user_id, puuid]
    )
  end

  # Queue listening events
  def queue_league_account_match_listening_event(puuid) do
    ErpcProxy.call_on_random_node(
      @erpc_proxy,
      @module,
      :queue_league_account_match_listening_event,
      [puuid]
    )
  end

  def queue_user_match_listening_event(user_id) do
    ErpcProxy.call_on_random_node(
      @erpc_proxy,
      @module,
      :queue_user_match_listening_event,
      [user_id]
    )
  end

  ### Deliver Emails
  def deliver_user_confirmation_instructions(user, url) do
    ErpcProxy.call_on_random_node(@erpc_proxy, @module, :deliver_user_confirmation_instructions, [
      user,
      url
    ])
  end

  def deliver_user_update_email_instructions(user, email, url) do
    ErpcProxy.call_on_random_node(@erpc_proxy, @module, :deliver_user_update_email_instructions, [
      user,
      email,
      url
    ])
  end

  def deliver_user_reset_password_instructions(user, url) do
    ErpcProxy.call_on_random_node(
      @erpc_proxy,
      @module,
      :deliver_user_reset_password_instructions,
      [
        user,
        url
      ]
    )
  end

  ### User Email
  def get_user_by_email(email) do
    ErpcProxy.call_on_random_node(@erpc_proxy, @module, :get_user_by_email, [email])
  end

  def change_user_email(user, params \\ %{}) do
    ErpcProxy.call_on_random_node(@erpc_proxy, @module, :change_user_email, [user, params])
  end

  def update_user_email(user, token) do
    ErpcProxy.call_on_random_node(@erpc_proxy, @module, :update_user_email, [user, token])
  end

  def get_user_by_email_and_password(email, password) do
    ErpcProxy.call_on_random_node(@erpc_proxy, @module, :get_user_by_email_and_password, [
      email,
      password
    ])
  end

  def apply_user_email(user, password, user_params) do
    ErpcProxy.call_on_random_node(@erpc_proxy, @module, :apply_user_email, [
      user,
      password,
      user_params
    ])
  end

  ### User Password
  def update_user_password(user, password, user_params) do
    ErpcProxy.call_on_random_node(@erpc_proxy, @module, :update_user_password, [
      user,
      password,
      user_params
    ])
  end

  def change_user_password(user, params \\ %{}) do
    ErpcProxy.call_on_random_node(@erpc_proxy, @module, :change_user_password, [user, params])
  end

  def reset_user_password(user, user_params) do
    ErpcProxy.call_on_random_node(@erpc_proxy, @module, :reset_user_password, [user, user_params])
  end

  def get_user_by_reset_password_token(token) do
    ErpcProxy.call_on_random_node(@erpc_proxy, @module, :get_user_by_reset_password_token, [token])
  end

  ### User Registration
  def register_user(user_params) do
    ErpcProxy.call_on_random_node(@erpc_proxy, @module, :register_user, [user_params])
  end

  def confirm_user(token) do
    ErpcProxy.call_on_random_node(@erpc_proxy, @module, :confirm_user, [token])
  end

  def change_user_registration(user, user_params \\ %{}) do
    ErpcProxy.call_on_random_node(@erpc_proxy, @module, :change_user_registration, [
      user,
      user_params
    ])
  end

  ### User Session Token
  def generate_user_session_token(user) do
    ErpcProxy.call_on_random_node(@erpc_proxy, @module, :generate_user_session_token, [user])
  end

  def delete_user_session_token(user_token) do
    ErpcProxy.call_on_random_node(@erpc_proxy, @module, :delete_user_session_token, [user_token])
  end

  def get_user_by_session_token(session_binary) do
    ErpcProxy.call_on_random_node(@erpc_proxy, @module, :get_user_by_session_token, [
      session_binary
    ])
  end
end
