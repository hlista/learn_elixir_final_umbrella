defmodule LearnElixirFinal.LeagueEventWorkers.LeagueAccountMatchListeningTest do
  use LearnElixirFinalPg.DataCase
  use Oban.Testing, repo: LearnElixirFinalPg.Repo
  import LearnElixirFinalPg.Factory
  import Mox

  setup :set_mox_from_context

  alias LearnElixirFinal.LeagueEventWorkers.{
    LeagueAccountMatchListening,
    LeagueMatchFound
  }

  @riot_api_key Application.compile_env(:riot_client, :riot_api_key)

  describe "@queue_event/1" do
    test "queue event assert" do
      LeagueAccountMatchListening.queue_event(%{puuid: "foo"})
      assert_enqueued worker: LeagueAccountMatchListening, args: %{puuid: "foo"}
    end

    test "queue uniqueness" do
      LeagueAccountMatchListening.queue_event(%{puuid: "foo"})
      LeagueAccountMatchListening.queue_event(%{puuid: "foo"})
      jobs = all_enqueued(worker: LeagueAccountMatchListening)
      assert 1 == length(jobs)
    end

    test "queue not unique" do
      LeagueAccountMatchListening.queue_event(%{puuid: "abc"})
      LeagueAccountMatchListening.queue_event(%{puuid: "efg"})
      jobs = all_enqueued(worker: LeagueAccountMatchListening)
      assert 2 == length(jobs)
    end
  end

  describe "@bulk_queue_events/1" do
    test "queue event assert" do
      league_accounts = [
        %{id: 1},
        %{id: 2},
      ]
      LeagueAccountMatchListening.bulk_queue_events(league_accounts)
      assert_enqueued(
        worker: LeagueAccountMatchListening,
        args: %{league_account_id: 1}
      )
      assert_enqueued(
        worker: LeagueAccountMatchListening,
        args: %{league_account_id: 2}
      )
    end

    test "queue uniqueness" do
      league_accounts = [
        %{id: 1},
        %{id: 1}
      ]
      LeagueAccountMatchListening.bulk_queue_events(league_accounts)
      jobs = all_enqueued(worker: LeagueAccountMatchListening)
      assert 1 == length(jobs)
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
        LeagueAccountMatchListening,
        %{puuid: "foobar"},
        queue: :league_listening
      )
    end

    test "riot player not found" do
      url = "https://americas.api.riotgames.com/riot/account/v1/accounts/by-puuid/foobar?api_key=#{@riot_api_key}"
      mock_invalid_player(HttpClientMock, url)
      assert {:ok, "Player does not exist"} = perform_job(
        LeagueAccountMatchListening,
        %{puuid: "foobar"},
        queue: :league_listening
      )
    end

    test "database player not found" do
      assert {:ok, "Player does not exist"} = perform_job(
        LeagueAccountMatchListening,
        %{league_account_id: 0},
        queue: :league_listening
      )
    end

    test "Invalid account params" do
      assert {:ok, "Invalid account params"} = perform_job(
        LeagueAccountMatchListening,
        %{},
        queue: :league_listenings
      )
    end

    test "Success league account in db", %{league_account: %{puuid: puuid, match_region: match_region}} do
      match_ids = ["match_1", "match_2", "match_3"]
      url = "https://#{match_region}.api.riotgames.com/lol/match/v5/matches/by-puuid/#{puuid}/ids?start=0&count=5&api_key=#{@riot_api_key}"
      mock_200(HttpClientMock, url, match_ids)
      assert :ok = perform_job(
        LeagueAccountMatchListening,
        %{puuid: puuid},
        queue: :league_listening
      )
      Enum.each(match_ids, &assert_enqueued(worker: LeagueMatchFound, args: %{match_id: &1, region: match_region}))
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
        LeagueAccountMatchListening,
        %{puuid: puuid},
        queue: :league_listening
      )
      Enum.each(match_ids, &assert_enqueued(worker: LeagueMatchFound, args: %{match_id: &1, region: region}))
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
        LeagueAccountMatchListening,
        %{league_account_id: league_account.id},
        queue: :league_listening
      )
      Enum.each(match_ids, &assert_enqueued(worker: LeagueMatchFound, args: %{match_id: &1, region: region}))
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
end
