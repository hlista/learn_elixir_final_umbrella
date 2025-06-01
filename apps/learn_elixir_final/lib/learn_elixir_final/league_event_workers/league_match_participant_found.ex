defmodule LearnElixirFinal.LeagueEventWorkers.LeagueMatchParticipantFound do
  use Oban.Worker

  @default_job_params [
    worker: __MODULE__,
    unique: [
      period: {2, :minutes},
      timestamp: :scheduled_at,
      keys: [:participant],
      fields: [:worker, :args]
    ]
  ]

  alias LearnElixirFinalPg.League

  alias LearnElixirFinal.LeagueEventWorkers.{
    AggregateLeagueAccountMatches,
    AggregateUserMatches
  }

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{
          "participant" => league_match_participant_info
        }
      }) do
    with {:ok, _} <-
           League.find_or_create_league_account(%{
             puuid: league_match_participant_info["puuid"]
           }),
         {:ok,
          %{
            users: users,
            league_accounts: league_accounts
          }} <-
           maybe_create_league_match_participant(
             league_match_participant_info
           ) do
      AggregateUserMatches.bulk_queue_events(users)
      AggregateLeagueAccountMatches.bulk_queue_events(league_accounts)
      :ok
    end
  end

  def bulk_queue_events(participants_info, region) do
    Enum.each(participants_info, fn participant_info ->
      params = %{
        participant: participant_info,
        region: region
      }
      opts = [queue: get_region_queue(region)] ++ @default_job_params
      params
      |> Oban.Job.new(opts)
      |> Oban.insert()
    end)
  end

  defp get_region_queue(region) do
    case region do
      "americas" -> :league_match_participant_americas
      "europe" -> :league_match_participant_europe
      "asia" -> :league_match_participant_asia
      "sea" -> :league_match_participant_sea
      _ -> :league_match_participant
    end
  end

  def maybe_create_league_match_participant(participant_info) do
    participant_info = participant_info
    |> Enum.map(fn {k, v} -> {String.to_existing_atom(k), v} end)
    |> Enum.into(%{})
    case League.find_match_participant(%{puuid: participant_info.puuid, league_match_id: participant_info.league_match_id}) do
      {:ok, _} -> {:ok, "participant already created"}
      {:error, _} ->
        create_league_match_participant(participant_info)
    end
  end

  def create_league_match_participant(participant_info) do
    with {:ok, league_match_participant} <- League.create_match_participant(participant_info) do
      %{users: users, league_accounts: league_accounts} =
        League.preload_match_participants_users_and_league_accounts(league_match_participant)
      {:ok, %{
        league_match_participant: league_match_participant,
        users: users,
        league_accounts: league_accounts
      }}
    end
  end
end
