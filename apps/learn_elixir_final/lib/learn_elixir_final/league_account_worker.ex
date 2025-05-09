defmodule LearnElixirFinal.LeagueAccountWorker do
  use Oban.Worker, queue: :league_accounts
  alias LearnElixirFinal.RiotClient

  @impl Oban.Worker
  def perform(%Oban.Job{args: league_account}) do
    with {:ok, updated_league_account} <-
        populate_puuid(league_account) do
      populate_matches(updated_league_account)
    end
  end

  defp populate_puuid(%{
    id: id,
    region: region,
    tag_line: tag_line,
    game_name: game_name
  }) do
    with {:ok, %{"puuid" => puuid}} <-
        RiotClient.get_account_by_riot_id(region, game_name, tag_line) do
      Leagues.update_league_account(id, %{puuid: puuid})
    end
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
      chunk_of_match_ids
      |> Enum.map(&(%{match_id: &1}))
      |> Leagues.insert_all_league_matches()
    end)
  end
end
