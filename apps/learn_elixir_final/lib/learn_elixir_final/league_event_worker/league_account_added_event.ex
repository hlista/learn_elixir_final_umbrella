defmodule LearnElixirFinal.LeagueEventWorker.LeagueAccountAddedEvent do
  alias LearnElixirFinalPg.League
  def create_players_matches(league_account_id) do
    with {:ok, %{
      id: ^league_account_id,
      match_region: match_region,
      puuid: puuid,
      match_offset: match_offset,
    }} <- League.find_league_account(%{id: league_account_id}) do
      riot_match_stream(league_account_id, puuid, match_region, match_offset)
      |> Stream.chunk_every(100)
      |> Stream.map(fn chunk_of_match_ids ->
        insert_match_ids(chunk_of_match_ids, match_region)
      end)
      |> Enum.reduce([],
        fn {:ok, schemas}, acc ->
            acc ++ schemas
          {:error, _}, acc ->
            acc
        end)
      |> then(& {:ok, &1})
    end
  end

  def riot_match_stream(league_account_id, puuid, match_region, match_offset) do
    Stream.resource(
      fn -> match_offset end,
      fn cursor ->
        case  RiotClient.get_account_match_ids(match_region, puuid, cursor, 100) do
          {:ok, []} -> {:halt, cursor}
          {:ok, matches} -> {matches, cursor + length(matches)}
          _ -> {:halt, cursor}
        end
      end,
      fn cursor -> League.update_league_account(league_account_id, %{match_offset: cursor}) end
    )
  end

  def insert_match_ids(match_ids, match_region) do
    match_ids
    |> Enum.map(&(%{match_id: &1, region: match_region}))
    |> League.find_or_create_many_league_match()
  end
end
