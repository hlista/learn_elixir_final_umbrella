defmodule LearnElixirFinal.LeagueMatchWorker do
  use Oban.Worker,
    queue: :league_matches,
    max_attempts: 10,
    unique: [period: 300, states: [:available, :scheduled, :executing]]
  alias LearnElixirFinalPg.League

  @impl Oban.Worker
  def perform(%Oban.Job{args: league_match}) do
    with {:ok, match} <- RiotClient.get_match(league_match.region, league_match.match_id) do
      metadata = match["metadata"]
      info = match["info"]
      participants = metadata["participants"]
      update_match_info(league_match.id, info)
      populate_participants_league_accounts(participants)
      populate_match_participants(league_match.id, info["participants"])
      notify_participants(participants, league_match.match_id)
    end
  end

  defp notify_participants(participants, match_id) do
    :ok
  end

  defp update_match_info(league_match_id, info) do
    match_update_fields = %{
      game_duration: info["gameDuration"],
      game_end_timestamp: info["gameEndTimestamp"],
      game_id: info["gameId"],
      game_name: info["gameName"]
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

  def queue_many_matches(league_matches) do
    league_matches
    |> Enum.map(&LearnElixirFinal.LeagueMatchWorker.new(&1))
    |> Oban.insert_all()
  end

  def populate_participants_league_accounts(participants) do
    res = participants
    |> Enum.map(&%{puuid: &1})
    |> League.find_or_create_many_league_account()
    with {:ok, schemas} <- res do
      query_riot_and_update_accounts(schemas)
    end
  end

  def query_riot_and_update_accounts(schemas) do
    Enum.each(schemas, fn league_account ->
      with {:ok, account_info} <- RiotClient.get_account_by_puuid(league_account.puuid) do
        League.update_league_account(league_account, %{
          game_name: account_info["gameName"],
          tag_line: account_info["tagLine"]
        })
      end
    end)
  end
end
