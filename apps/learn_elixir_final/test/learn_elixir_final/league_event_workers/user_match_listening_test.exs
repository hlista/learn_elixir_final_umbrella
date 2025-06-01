defmodule LearnElixirFinal.LeagueEventWorkers.UserMatchListeningTest do
  use LearnElixirFinalPg.DataCase
  use Oban.Testing, repo: LearnElixirFinalPg.Repo
  import LearnElixirFinalPg.Factory
  import Mox

  setup :set_mox_from_context

  alias LearnElixirFinal.LeagueEventWorkers.{
    UserMatchListening,
    LeagueAccountMatchListening
  }

  describe "@queue_event/1" do
    test "queue event assert" do
      UserMatchListening.queue_event(5)
      assert_enqueued worker: UserMatchListening, args: %{user_id: 5}
    end

    test "queue uniqueness"  do
      UserMatchListening.queue_event(5)
      UserMatchListening.queue_event(5)
      jobs = all_enqueued(worker: UserMatchListening)
      assert 1 == length(jobs)
    end

    test "queue not unique" do
      UserMatchListening.queue_event(5)
      UserMatchListening.queue_event(6)
      jobs = all_enqueued(worker: UserMatchListening)
      assert 2 == length(jobs)
    end
  end

  describe "perform user match listening event" do
    setup do
      user_with_league_accounts = insert(:user, %{league_accounts: [build(:league_account), build(:league_account)]})
      user_without_league_accounts = insert(:user)
      %{
        user_with_league_accounts: user_with_league_accounts,
        user_without_league_accounts: user_without_league_accounts
      }
    end
    test "user with league accounts", %{user_with_league_accounts: user} do
      perform_job(
        UserMatchListening,
        %{
          user_id: user.id
        }, queue: :league_listening
      )
      league_accounts = user.league_accounts
      Enum.each(league_accounts,
          &assert_enqueued(
            worker: LeagueAccountMatchListening,
            args: %{league_account_id: &1.id}
          )
      )
    end
    test "user with no league accounts", %{user_without_league_accounts: user} do
      perform_job(
        UserMatchListening,
        %{
          user_id: user.id
        }, queue: :league_listening
      )
      jobs = all_enqueued(worker: LeagueAccountMatchListening)
      assert true == Enum.empty?(jobs)
    end

    test "user does not exist" do
      assert {:ok, "User does not exist"} = perform_job(
        UserMatchListening,
        %{
          user_id: 0
        }, queue: :league_listening
      )
    end
  end
end
