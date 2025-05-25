defmodule LearnElixirFinal.LeagueEventWorkerTest do
  use LearnElixirFinalPg.DataCase
  use Oban.Testing, repo: LearnElixirFinalPg.Repo
  import LearnElixirFinalPg.Factory
  import Mox

  setup :set_mox_from_context

  alias LearnElixirFinal.LeagueEventWorker

  @riot_api_key Application.compile_env(:riot_client, :riot_api_key)

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
      assert_enqueued worker: LeagueEventWorker, args: %{match_id: "match_1", event: "league_match_found_event"}
      assert_enqueued worker: LeagueEventWorker, args: %{match_id: "match_2", event: "league_match_found_event"}
      assert_enqueued worker: LeagueEventWorker, args: %{match_id: "match_3", event: "league_match_found_event"}
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
      assert true == Enum.empty?(jobs)
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
      league_account_no_puuid = insert(
        :league_account,
        puuid: nil,
        region: nil,
        match_region: nil
      )
      %{
        league_account: league_account,
        league_account_no_puuid: league_account_no_puuid
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

    test "Success league account in db", %{league_account: %{puuid: puuid, match_region: match_region}} do
      match_ids = ["match_1", "match_2", "match_3"]
      url = "https://#{match_region}.api.riotgames.com/lol/match/v5/matches/by-puuid/#{puuid}/ids?start=0&count=5&api_key=#{@riot_api_key}"
      mock_200(HttpClientMock, url, match_ids)
      assert :ok = perform_job(
        LeagueEventWorker,
        %{
          params: %{puuid: puuid},
          event: LeagueEventWorker.league_account_match_listening_event
        }, queue: :league_events
      )
      Enum.each(match_ids, &assert_enqueued(worker: LeagueEventWorker, args: %{match_id: &1, event: "league_match_found_event", region: match_region}))
    end

    test "Success league account not in db by puuid", _ do
      match_ids = ["match_1", "match_2", "match_3"]
      puuid = "foobar"
      region = "americas"
      player_url = "https://#{region}.api.riotgames.com/riot/account/v1/accounts/by-puuid/#{puuid}?api_key=#{@riot_api_key}"
      region_url = "https://#{region}.api.riotgames.com/riot/account/v1/region/by-game/lol/by-puuid/#{puuid}?api_key=#{@riot_api_key}"
      match_url = "https://#{region}.api.riotgames.com/lol/match/v5/matches/by-puuid/#{puuid}/ids?start=0&count=5&api_key=#{@riot_api_key}"
      mock_200(HttpClientMock, player_url, %{
        "gameName" => "game_name",
        "tagLine" => "tag_line"
      })
      mock_200(HttpClientMock, region_url, %{
        "region" => "na"
      })
      mock_200(HttpClientMock, match_url, match_ids)
      assert :ok = perform_job(
        LeagueEventWorker,
        %{
          params: %{puuid: puuid},
          event: LeagueEventWorker.league_account_match_listening_event
        }, queue: :league_events
      )
      Enum.each(match_ids, &assert_enqueued(worker: LeagueEventWorker, args: %{match_id: &1, event: "league_match_found_event", region: region}))
    end

    test "Success league account not in db no puuid", %{league_account_no_puuid: league_account} do
      match_ids = ["match_1", "match_2", "match_3"]
      puuid = "foobar"
      game_name = league_account.game_name
      tag_line = league_account.tag_line
      region = "americas"
      player_url = "https://#{region}.api.riotgames.com/riot/account/v1/accounts/by-riot-id/#{game_name}/#{tag_line}?api_key=#{@riot_api_key}"
      region_url = "https://#{region}.api.riotgames.com/riot/account/v1/region/by-game/lol/by-puuid/#{puuid}?api_key=#{@riot_api_key}"
      match_url = "https://#{region}.api.riotgames.com/lol/match/v5/matches/by-puuid/#{puuid}/ids?start=0&count=5&api_key=#{@riot_api_key}"
      mock_200(HttpClientMock, player_url, %{
        "puuid" => puuid,
      })
      mock_200(HttpClientMock, region_url, %{
        "region" => "na"
      })
      mock_200(HttpClientMock, match_url, match_ids)
      assert :ok = perform_job(
        LeagueEventWorker,
        %{
          params: %{league_account_id: league_account.id},
          event: LeagueEventWorker.league_account_match_listening_event
        }, queue: :league_events
      )
      Enum.each(match_ids, &assert_enqueued(worker: LeagueEventWorker, args: %{match_id: &1, event: "league_match_found_event", region: region}))
    end
  end

  describe "perform league_match_found_event" do
    test "Api key expired" do
      match_id = "match_1"
      region = "americas"
      url = "https://#{region}.api.riotgames.com/lol/match/v5/matches/#{match_id}?api_key=#{@riot_api_key}"
      mock_invalid_api_key(HttpClientMock, url)
      assert {:ok, _} = perform_job(
        LeagueEventWorker,
        %{
          match_id: match_id,
          region: region,
          event: LeagueEventWorker.league_match_found_event
        }, queue: :league_events_americas
      )
    end

    test "resource not found" do
      match_id = "match_1"
      region = "americas"
      url = "https://#{region}.api.riotgames.com/lol/match/v5/matches/#{match_id}?api_key=#{@riot_api_key}"
      mock_resource_not_found(HttpClientMock, url)
      assert {:ok, _} = perform_job(
        LeagueEventWorker,
        %{
          match_id: match_id,
          region: region,
          event: LeagueEventWorker.league_match_found_event
        }, queue: :league_events_americas
      )
    end

    test "match already made" do
      league_match = insert(:league_match)
      expected_payload = %{
        "metadata" => %{
          "matchId" => league_match.match_id,
        }
      }
      url = "https://#{league_match.region}.api.riotgames.com/lol/match/v5/matches/#{league_match.match_id}?api_key=#{@riot_api_key}"
      mock_200(HttpClientMock, url, expected_payload)
      assert {:ok, "League Match Already Created"} = perform_job(
        LeagueEventWorker,
        %{
          match_id: league_match.match_id,
          region: league_match.region,
          event: LeagueEventWorker.league_match_found_event
        }, queue: :league_events_americas
      )
    end

    test "Success" do
      match_participant = params_for(:match_participant)
      |> Map.update!(:game_end_timestamp, &(DateTime.to_unix(&1, :millisecond)))
      |> camel_cased_map_keys()
      league_match = params_for(:league_match)
      |> Map.put(:participants, [match_participant])
      |> Map.update!(:game_end_timestamp, &(DateTime.to_unix(&1, :millisecond)))
      |> camel_cased_map_keys()

      match_id = league_match["matchId"]
      participants = [match_participant["puuid"]]
      region = league_match["region"]
      expected_payload = %{
        "metadata" => %{
          "matchId" => match_id,
          "participants" => participants
        },
        "info" => league_match
      }
      url = "https://#{region}.api.riotgames.com/lol/match/v5/matches/#{match_id}?api_key=#{@riot_api_key}"
      mock_200(HttpClientMock, url, expected_payload)
      :ok = perform_job(
        LeagueEventWorker,
        %{
          match_id: match_id,
          region: region,
          event: LeagueEventWorker.league_match_found_event
        }, queue: :league_events_americas
      )
      jobs = all_enqueued(worker: LeagueEventWorker)
      assert 1 == length(jobs)
    end
  end

  describe "perform league_match_participant_found_event" do
    test "Success" do
      league_match = insert(:league_match)
      match_participant = params_for(:match_participant, league_match_id: league_match.id)
      league_account = insert(:league_account, puuid: match_participant.puuid)
      :ok = perform_job(
        LeagueEventWorker,
        %{
          participant: match_participant,
          region: league_match.region,
          event: LeagueEventWorker.league_match_participant_found_event()
        }, queue: :league_events
      )
      assert_enqueued(worker: LeagueEventWorker, args: %{league_account_id: league_account.id, event: LeagueEventWorker.aggregate_league_account_matches_event()})
    end

    test "create league account if doesnt exist" do
      league_match = insert(:league_match)
      match_participant = params_for(:match_participant, league_match_id: league_match.id)
      assert :ok = perform_job(
        LeagueEventWorker,
        %{
          participant: match_participant,
          region: league_match.region,
          event: LeagueEventWorker.league_match_participant_found_event()
        }, queue: :league_events
      )
      jobs = all_enqueued(worker: LeagueEventWorker)
      assert 1 == length(jobs)
    end
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

  def mock_200(mock_module, url, payload) do
    body = Jason.encode!(payload)
    expect(
      mock_module, :request,
        fn :get, ^url, _headers, _body, _opts ->
          {:ok, %Finch.Response{status: 200, body: body}}
        end
      )
  end

  defp camel_cased_map_keys(map) when is_map(map) do
    for {key, val} <- map, into: %{} do
      {Inflex.camelize(key, :lower), camel_cased_map_keys(val)}
    end
  end

  defp camel_cased_map_keys(val), do: val
end
