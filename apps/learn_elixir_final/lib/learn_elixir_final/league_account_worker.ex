defmodule LearnElixirFinal.LeagueAccountWorker do
  use Oban.Worker,
    queue: :league_accounts,
    max_attempts: 10,
    unique: [period: 300, states: [:available, :scheduled, :executing]]

  alias LearnElixirFinalPg.Leagues

  @impl Oban.Worker
  def perform(%Oban.Job{args: league_account}) do
    populate_matches(league_account, "americas")
    populate_matches(league_account, "asia")
    populate_matches(league_account, "europe")
    populate_matches(league_account, "sea")
  end

  defp populate_matches(%{
    id: id,
    puuid: puuid,
    match_offset: match_offset
  }, region) do
    Stream.resource(
      fn -> match_offset end,
      fn cursor ->
        case  RiotClient.get_match_ids(region, puuid, cursor, 100) do
          {:ok, matches} -> {matches, cursor + length(matches)}
          _ -> {:halt, cursor}
        end
      end,
      fn cursor -> Leagues.update_league_account(id, %{match_offset: cursor}) end
    )
    |> Stream.chunk_every(100)
    |> Stream.each(fn chunk_of_match_ids ->
      matches = chunk_of_match_ids
      |> Enum.map(&(%{match_id: &1, region: region}))
      |> Leagues.find_or_create_many_league_match()
      LearnElixirFinal.LeagueMatchWorker.queue_many_matches(matches)
    end)
    |> Stream.run()
  end

  def queue_account(league_account) do
    league_account
    |> LearnElixirFinal.LeagueAccountWorker.new()
    |> Oban.insert()
  end
end
