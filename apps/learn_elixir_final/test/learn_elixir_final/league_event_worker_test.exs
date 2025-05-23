defmodule LearnElixirFinal.LeagueEventWorkerTest do
  use LearnElixirFinalPg.DataCase
  use Oban.Testing, repo: LearnElixirFinalPg.Repo
  import LearnElixirFinalPg.Factory
  import Mox

  setup :set_mox_from_context

  alias LearnElixirFinal.LeagueEventWorker

  @riot_api_key Application.get_env(:riot_client, :riot_api_key)

  describe "@queue_user_match_listening_event/1" do
    test "queue event assert" do
      LeagueEventWorker.queue_user_match_listening_event(5)
      assert_enqueued worker: LeagueEventWorker, args: %{user_id: 5, event: "user_match_listening_event"}
    end

    test "queue uniqueness"  do
      LeagueEventWorker.queue_user_match_listening_event(5)
      LeagueEventWorker.queue_user_match_listening_event(5)
      jobs = all_enqueued(worker: LeagueEventWorker)
      assert 1 == length(jobs)
    end

    test "queue not unique" do
      LeagueEventWorker.queue_user_match_listening_event(5)
      LeagueEventWorker.queue_user_match_listening_event(6)
      jobs = all_enqueued(worker: LeagueEventWorker)
      assert 2 == length(jobs)
    end
  end

  describe "@queue_league_account_match_listening_event/1" do
    test "queue event assert" do
      LeagueEventWorker.queue_league_account_match_listening_event(%{puuid: "foo"})
      assert_enqueued worker: LeagueEventWorker, args: %{params: %{puuid: "foo"}, event: "league_account_match_listening_event"}
    end

    test "queue uniqueness" do
      LeagueEventWorker.queue_league_account_match_listening_event(%{puuid: "foo"})
      LeagueEventWorker.queue_league_account_match_listening_event(%{puuid: "foo"})
      jobs = all_enqueued(worker: LeagueEventWorker)
      assert 1 == length(jobs)
    end

    test "queue not unique" do
      LeagueEventWorker.queue_league_account_match_listening_event(%{puuid: "abc"})
      LeagueEventWorker.queue_league_account_match_listening_event(%{puuid: "efg"})
      jobs = all_enqueued(worker: LeagueEventWorker)
      assert 2 == length(jobs)
    end
  end

  describe "@bulk_queue_league_account_match_listening_event/1" do
    test "queue event assert" do
      league_accounts = [
        %{id: 1, match_region: "americas"},
        %{id: 2, match_region: "europe"},
        %{id: 3, match_region: "sea"},
        %{id: 4, match_region: "asia"}
      ]
      LeagueEventWorker.bulk_queue_league_account_match_listening_event(league_accounts)
      assert_enqueued(
        worker: LeagueEventWorker,
        args: %{params: %{league_account_id: 1}, event: "league_account_match_listening_event"},
        queue: :league_events_americas
      )
      assert_enqueued(
        worker: LeagueEventWorker,
        args: %{params: %{league_account_id: 2}, event: "league_account_match_listening_event"},
        queue: :league_events_europe
      )
      assert_enqueued(
        worker: LeagueEventWorker,
        args: %{params: %{league_account_id: 3}, event: "league_account_match_listening_event"},
        queue: :league_events_sea
      )
      assert_enqueued(
        worker: LeagueEventWorker,
        args: %{params: %{league_account_id: 4}, event: "league_account_match_listening_event"},
        queue: :league_events_asia
      )
    end

    test "queue uniqueness" do
      league_accounts = [
        %{id: 1, match_region: "americas"},
        %{id: 1, match_region: "europe"},
      ]
      LeagueEventWorker.bulk_queue_league_account_match_listening_event(league_accounts)
      jobs = all_enqueued(worker: LeagueEventWorker)
      assert 1 == length(jobs)
    end
  end

  describe "@bulk_queue_league_match_found_event/2" do
    test "queue event assert" do
      match_ids = ["match_1", "match_2", "match_3"]
      LeagueEventWorker.bulk_queue_league_match_found_event(match_ids, "americas")
      assert_enqueued worker: LeagueEventWorker, args: %{league_match_id: "match_1", event: "league_match_found_event"}
      assert_enqueued worker: LeagueEventWorker, args: %{league_match_id: "match_2", event: "league_match_found_event"}
      assert_enqueued worker: LeagueEventWorker, args: %{league_match_id: "match_3", event: "league_match_found_event"}
    end

    test "queue uniqueness" do
      match_ids = ["match_1", "match_1"]
      LeagueEventWorker.bulk_queue_league_match_found_event(match_ids, "americas")
      jobs = all_enqueued(worker: LeagueEventWorker)
      assert 1 == length(jobs)
    end
  end

  describe "@bulk_queue_league_match_participant_found_event/2" do
    test "queue event assert" do
      match_participant = params_for(:match_participant)
      match_participants = [match_participant]
      LeagueEventWorker.bulk_queue_league_match_participant_found_event(match_participants, "americas")
      assert_enqueued worker: LeagueEventWorker, args: %{participant: match_participant, event: "league_match_participant_found_event"}
    end

    test "queue uniqueness" do
      match_participant = params_for(:match_participant)
      match_participants = [match_participant, match_participant]
      LeagueEventWorker.bulk_queue_league_match_participant_found_event(match_participants, "americas")
      jobs = all_enqueued(worker: LeagueEventWorker)
      assert 1 == length(jobs)
    end
  end

  describe "@bulk_queue_aggregate_user_matches_event/2" do
    test "queue event assert" do
      LeagueEventWorker.bulk_queue_aggregate_user_matches_event([%{id: 2}, %{id: 3}])
      assert_enqueued(worker: LeagueEventWorker, args: %{user_id: 2, event: "aggregate_user_matches_event"}, queue: :league_events)
      assert_enqueued(worker: LeagueEventWorker, args: %{user_id: 3, event: "aggregate_user_matches_event"}, queue: :league_events)
    end

    test "queue uniqueness" do
      users = [%{id: 2}, %{id: 2}]
      LeagueEventWorker.bulk_queue_aggregate_user_matches_event(users)
      jobs = all_enqueued(worker: LeagueEventWorker)
      assert 1 == length(jobs)
    end
  end

  describe "@bulk_queue_aggregate_league_account_matches_event/2" do
    test "queue event assert" do
      LeagueEventWorker.bulk_queue_aggregate_league_account_matches_event([%{id: 2}, %{id: 3}])
      assert_enqueued(worker: LeagueEventWorker, args: %{league_account_id: 2, event: "aggregate_league_account_matches_event"}, queue: :league_events)
      assert_enqueued(worker: LeagueEventWorker, args: %{league_account_id: 3, event: "aggregate_league_account_matches_event"}, queue: :league_events)
    end

    test "queue uniqueness" do
      league_accounts = [%{id: 2}, %{id: 2}]
      LeagueEventWorker.bulk_queue_aggregate_league_account_matches_event(league_accounts)
      jobs = all_enqueued(worker: LeagueEventWorker)
      assert 1 == length(jobs)
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
        LeagueEventWorker,
        %{
          user_id: user.id,
          event: LeagueEventWorker.user_match_listening_event
        }, queue: :league_events
      )
      league_accounts = user.league_accounts
      Enum.each(league_accounts,
          &assert_enqueued(
            worker: LeagueEventWorker,
            args: %{params: %{league_account_id: &1.id},
            event: "league_account_match_listening_event"
          })
      )
    end
    test "user with no league accounts", %{user_without_league_accounts: user} do
      perform_job(
        LeagueEventWorker,
        %{
          user_id: user.id,
          event: LeagueEventWorker.user_match_listening_event
        }, queue: :league_events
      )
      jobs = all_enqueued(worker: LeagueEventWorker)
      assert 0 == length(jobs)
    end

    test "user does not exist" do
      assert {:ok, "User does not exist"} = perform_job(
        LeagueEventWorker,
        %{
          user_id: 0,
          event: LeagueEventWorker.user_match_listening_event
        }, queue: :league_events
      )
    end
  end


  describe "perform league account match listening event" do
    setup do
      league_account = insert(:league_account)
      %{
        league_account: league_account
      }
    end
    test "Api key expired" do
      url = "https://americas.api.riotgames.com/riot/account/v1/accounts/by-puuid/foobar?api_key=#{@riot_api_key}"
      mock_invalid_api_key(HttpClientMock, url)
      assert {:ok, "Api Key expired"} = perform_job(
        LeagueEventWorker,
        %{
          params: %{puuid: "foobar"},
          event: LeagueEventWorker.league_account_match_listening_event
        }, queue: :league_events
      )
    end

    test "riot player not found" do
      url = "https://americas.api.riotgames.com/riot/account/v1/accounts/by-puuid/foobar?api_key=#{@riot_api_key}"
      mock_invalid_player(HttpClientMock, url)
      assert {:ok, "Player does not exist"} = perform_job(
        LeagueEventWorker,
        %{
          params: %{puuid: "foobar"},
          event: LeagueEventWorker.league_account_match_listening_event
        }, queue: :league_events
      )
    end

    test "database player not found" do
      assert {:ok, "Player does not exist"} = perform_job(
        LeagueEventWorker,
        %{
          params: %{league_account_id: 0},
          event: LeagueEventWorker.league_account_match_listening_event
        }, queue: :league_events
      )
    end

    test "Invalid account params" do
      assert {:ok, "Invalid account params"} = perform_job(
        LeagueEventWorker,
        %{
          params: %{},
          event: LeagueEventWorker.league_account_match_listening_event
        }, queue: :league_events
      )
    end
    # test "user with no league accounts", %{user_without_league_accounts: user} do
    #   perform_job(
    #     LeagueEventWorker,
    #     %{
    #       user_id: user.id,
    #       event: LeagueEventWorker.user_match_listening_event
    #     }, queue: :league_events
    #   )
    #   jobs = all_enqueued(worker: LeagueEventWorker)
    #   assert 0 == length(jobs)
    # end

    # test "user does not exist" do
    #   assert {:ok, "User does not exist"} = perform_job(
    #     LeagueEventWorker,
    #     %{
    #       user_id: 0,
    #       event: LeagueEventWorker.user_match_listening_event
    #     }, queue: :league_events
    #   )
    # end
  end

  def mock_invalid_api_key(mock_module, url) do
    body = Jason.encode!(%{
      "status" => %{
        "message" => "Unknown apikey",
        "status_code" => 401
    }})
    expect(
      mock_module, :request,
        fn :get, ^url, _headers, _body, _opts ->
          {:ok, %Finch.Response{status: 401, body: body}}
        end
      )
  end

  def mock_invalid_player(mock_module, url) do
    body = Jason.encode!(%{
      "status" => %{
        "message" => "Bad Request - Exception decrypting ",
        "status_code" => 400
    }})
    expect(
      mock_module, :request,
        fn :get, ^url, _headers, _body, _opts ->
          {:ok, %Finch.Response{status: 400, body: body}}
        end
      )
  end

  def mock_resource_not_found(mock_module, url) do
    body = Jason.encode!(%{
      "errorCode" => "RESOURCE_NOT_FOUND",
      "httpStatus" => 404,
    })
    expect(
      mock_module, :request,
        fn :get, ^url, _headers, _body, _opts ->
          {:ok, %Finch.Response{status: 404, body: body}}
        end
      )
  end
end



# def handle_error_code(%{
#   "status" => %{
#     "message" => "Unknown apikey",
#     "status_code" => 401
# }}) do
#   {:error, "Invalid Api Key"}
# end

# def handle_error_code(%{
#   "status" => %{
#     "message" => "Bad Request - Exception decrypting" <> _,
#     "status_code" => 400
# }}) do
#   {:error, "Invalid player"}
# end

# def handle_error_code(%{
#   "status" => %{
#     "message" => "Data not found - No results found for player" <> _,
#     "status_code" => 404
#   }
# }) do
#   {:error, "Invalid player"}
# end

# def handle_error_code(%{
#   "errorCode" => "RESOURCE_NOT_FOUND",
#   "httpStatus" => 404,
# }) do
#   {:error, "resource not found"}
# end
