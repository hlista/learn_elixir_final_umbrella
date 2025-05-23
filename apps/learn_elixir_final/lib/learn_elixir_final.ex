defmodule LearnElixirFinal do
  alias LearnElixirFinalPg.Accounts
  alias LearnElixirFinal.{
    LeagueAccount,
    LeagueEventWorker
  }

  # Handle League Account
  defdelegate add_user_league_account_by_game_name_tag_line(user_id, game_name, tag_line), to: LeagueAccount

  defdelegate add_user_league_account_by_puuid(user_id, puuid), to: LeagueAccount

  defdelegate remove_user_league_account(user_id, puuid), to: LeagueAccount

  # Queue Events
  defdelegate queue_league_account_match_listening_event(params), to: LeagueEventWorker
  defdelegate queue_user_match_listening_event(user_id), to: LeagueEventWorker

  ### Deliver Emails
  def deliver_user_confirmation_instructions(user, url) do
    url_fun = &("#{url}#{&1}")
    Accounts.deliver_user_confirmation_instructions(user, url_fun)
  end

  def deliver_user_update_email_instructions(user, email, url) do
    url_fun = &("#{url}#{&1}")
    Accounts.deliver_user_update_email_instructions(user, email, url_fun)
  end

  def deliver_user_reset_password_instructions(user, url) do
    url_fun = &("#{url}#{&1}")
    Accounts.deliver_user_reset_password_instructions(user, url_fun)
  end

  ### User Email
  defdelegate get_user_by_email(email), to: Accounts
  defdelegate change_user_email(user, params \\ %{}), to: Accounts
  defdelegate update_user_email(user, token), to: Accounts
  defdelegate get_user_by_email_and_password(email, password), to: Accounts
  defdelegate apply_user_email(user, password, user_params), to: Accounts

  ### User Password
  defdelegate update_user_password(user, password, user_params), to: Accounts
  defdelegate change_user_password(user, params \\ %{}), to: Accounts
  defdelegate reset_user_password(user, user_params), to: Accounts
  defdelegate get_user_by_reset_password_token(token), to: Accounts

  ### User Registration
  defdelegate register_user(user_params), to: Accounts
  defdelegate confirm_user(token), to: Accounts
  defdelegate change_user_registration(user, user_params \\ %{}), to: Accounts

  ### User Session Token
  defdelegate generate_user_session_token(user), to: Accounts
  defdelegate delete_user_session_token(user_token), to: Accounts
  defdelegate get_user_by_session_token(session_binary), to: Accounts
end
