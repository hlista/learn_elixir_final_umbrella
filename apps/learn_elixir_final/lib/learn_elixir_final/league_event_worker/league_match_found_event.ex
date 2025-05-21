defmodule LearnElixirFinal.LeagueEventWorker.LeagueMatchFoundEvent do
  alias LearnElixirFinalPg.League

  def maybe_create_league_match(match_id, region) do
    case League.find_league_match(%{match_id: match_id}) do
      {:ok, _} ->
        {:ok, "League Match Already Created"}
      {:error, _} ->
        create_league_match(match_id, region)
    end
  end

  def create_league_match(match_id, region) do
    with {:ok, match_payload} <- RiotClient.get_match(region, match_id),
         {:ok, league_match} <- League.create_league_match(match_create_fields(match_id, region, match_payload)),
         {:ok, match_participants_info} <- get_match_participants_info(league_match, match_payload["info"]["participants"]) do
      {:ok, %{
        league_match: league_match,
        match_participants_info: match_participants_info
      }}
    end
  end

  def match_create_fields(match_id, region, match_payload) do
    %{
      match_id: match_id,
      region: region,
      game_duration: match_payload["info"]["gameDuration"],
      game_end_timestamp: DateTime.from_unix!(match_payload["info"]["gameEndTimestamp"], :millisecond),
      game_id: match_payload["info"]["gameId"],
      game_name: match_payload["info"]["gameName"],
      participants: match_payload["metadata"]["participants"]
    }
  end

  def get_match_participants_info(league_match, participants) do
    Enum.map(participants, fn participant ->
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
        league_match_id: league_match.id,
        game_end_timestamp: league_match.game_end_timestamp
      }
    end)
  end
end
