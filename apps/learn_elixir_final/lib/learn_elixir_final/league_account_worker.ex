defmodule LearnElixirFinal.LeagueAccountWorker do
  use Oban.Worker,
    queue: :league_accounts,
    max_attempts: 10,
    unique: [period: 300, states: [:available, :scheduled, :executing]]

  alias LearnElixirFinal.RiotClient

  @impl Oban.Worker
  def perform(%Oban.Job{args: league_account}) do
    populate_matches(league_account)
  end

  defp populate_matches(%{
    id: id,
    region: region,
    puuid: puuid,
    match_offset: match_offset
  }) do
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
      {_, matches} = chunk_of_match_ids
      |> Enum.map(&(%{match_id: &1, region: region}))
      |> Leagues.insert_all_league_matches([returning: true])
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
