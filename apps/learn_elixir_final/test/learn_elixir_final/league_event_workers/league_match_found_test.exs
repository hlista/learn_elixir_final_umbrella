defmodule LearnElixirFinal.LeagueEventWorkers.LeagueMatchFoundTest do
  use LearnElixirFinalPg.DataCase
  use Oban.Testing, repo: LearnElixirFinalPg.Repo
  import LearnElixirFinalPg.Factory
  import Mox

  setup :set_mox_from_context

  alias LearnElixirFinal.LeagueEventWorkers.{
    LeagueMatchFound,
    LeagueMatchParticipantFound
  }

  @riot_api_key Application.compile_env(:riot_client, :riot_api_key)

  describe "@bulk_queue_events/2" do
    test "queue event assert" do
      match_ids = ["match_1", "match_2", "match_3"]
      LeagueMatchFound.bulk_queue_events(match_ids, "asia")
      assert_enqueued worker: LeagueMatchFound, args: %{match_id: "match_1"}, queue: :league_match_found_asia
      assert_enqueued worker: LeagueMatchFound, args: %{match_id: "match_2"}, queue: :league_match_found_asia
      assert_enqueued worker: LeagueMatchFound, args: %{match_id: "match_3"}, queue: :league_match_found_asia
    end

    test "queue uniqueness" do
      match_ids = ["match_1", "match_1"]
      LeagueMatchFound.bulk_queue_events(match_ids, "americas")
      jobs = all_enqueued(worker: LeagueMatchFound)
      assert 1 == length(jobs)
    end
  end


  describe "perform league_match_found_event" do
    test "Api key expired" do
      match_id = "match_1"
      region = "americas"
      url = "https://#{region}.api.riotgames.com/lol/match/v5/matches/#{match_id}?api_key=#{@riot_api_key}"
      mock_invalid_api_key(HttpClientMock, url)
      assert {:ok, _} = perform_job(
        LeagueMatchFound,
        %{
          match_id: match_id,
          region: region
        }, queue: :league_match_found_americas
      )
    end

    test "resource not found" do
      match_id = "match_1"
      region = "americas"
      url = "https://#{region}.api.riotgames.com/lol/match/v5/matches/#{match_id}?api_key=#{@riot_api_key}"
      mock_resource_not_found(HttpClientMock, url)
      assert {:ok, _} = perform_job(
        LeagueMatchFound,
        %{
          match_id: match_id,
          region: region
        }, queue: :league_match_found_americas
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
        LeagueMatchFound,
        %{
          match_id: league_match.match_id,
          region: league_match.region
        }, queue: :league_match_found_americas
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
        LeagueMatchFound,
        %{
          match_id: match_id,
          region: region
        }, queue: :league_match_found_americas
      )
      jobs = all_enqueued(worker: LeagueMatchParticipantFound)
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
