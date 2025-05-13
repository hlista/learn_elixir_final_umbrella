defmodule LearnElixirFinal.LeagueEventWorker.LeagueMatchAddedEvent do
  alias LearnElixirFinalPg.League
  def populate_match_info(league_match_id) do
    with {:ok, %{
      match_id: match_id,
      region: region
    }} <- League.find_league_match(%{id: league_match_id}),
      {:ok, match_payload} <- RiotClient.get_match(region, match_id),
      {:ok, league_match} <- update_league_match_info(league_match_id, match_payload),
      {:ok, match_participants} <- populate_match_participants(league_match.id, match_payload["info"]["participants"]) do
        {:ok, %{
          league_match: league_match,
          match_participants: match_participants
        }}
    end
  end

  def update_league_match_info(league_match_id, match_payload) do
    match_update_fields = %{
      game_duration: match_payload["info"]["gameDuration"],
      game_end_timestamp: DateTime.from_unix!(match_payload["info"]["gameEndTimestamp"], :millisecond),
      game_id: match_payload["info"]["gameId"],
      game_name: match_payload["info"]["gameName"],
      participants: match_payload["metadata"]["participants"]
    }
    League.update_league_match(league_match_id, match_update_fields)
  end

  defp populate_match_participants(league_match_id, participants) do
    participants
    |> Enum.map(fn participant ->
      %{
        puuid: participant["puuid"],
        assists: participant["assists"],
        baron_kills: participant["baronKills"],
        champ_experience: participant["champExperience"],
        champ_level: participant["champLevel"],
        champion_name: participant["championName"],
        damage_dealt_to_buildings: participant["damageDealtToBuildings"],
        damage_dealt_to_objectives: participant["damageDealtToObjectives"],
        damage_dealt_to_turrets: participant["damageDealtToTurrets"],
        damage_self_mitigated: participant["damageSelfMitigated"],
        deaths: participant["deaths"],
        gold_earned: participant["goldEarned"],
        gold_spent: participant["goldSpent"],
        kills: participant["kills"],
        largest_killing_spree: participant["largestKillingSpree"],
        largest_multi_kill: participant["largestMultiKill"],
        magic_damage_dealt: participant["magicDamageDealt"],
        magic_damage_dealt_to_champions: participant["magicDamageDealtToChampions"],
        magic_damage_taken: participant["magicDamageTaken"],
        physical_damage_dealt: participant["physicalDamageDealt"],
        physical_damage_dealt_to_champions: participant["physicalDamageDealtToChampions"],
        physical_damage_taken: participant["physicalDamageTaken"],
        total_damage_dealt: participant["totalDamageDealt"],
        total_damage_dealt_to_champions: participant["totalDamageDealtToChampions"],
        total_damage_taken: participant["totalDamageTaken"],
        total_heal: participant["totalHeal"],
        total_minions_killed: participant["totalMinionsKilled"],
        total_time_spent_dead: participant["totalTimeSpentDead"],
        win: participant["win"],
        league_match_id: league_match_id
      }
    end)
    |> League.find_or_create_many_match_participant()
  end
end
