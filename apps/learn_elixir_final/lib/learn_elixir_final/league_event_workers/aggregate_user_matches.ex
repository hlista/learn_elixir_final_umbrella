defmodule LearnElixirFinal.LeagueEventWorkers.AggregateUserMatches do
  use Oban.Worker,
  queue: :league_match_aggregate,
  unique: [
    period: {2, :minutes},
    timestamp: :scheduled_at,
    keys: [:user_id],
    fields: [:worker, :args]
  ],
  max_attempts: 5
  alias LearnElixirFinalPg.{
    Accounts,
    League
  }
  alias LearnElixirFinal.LearnElixirFinalWebProxy

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{
          "user_id" => user_id
        }
      }) do
    with {:ok, match_aggregate} <-
           update_user_match_aggregate(
             user_id
           ) do
      LearnElixirFinalWebProxy.publish(match_aggregate, :user_match_added, "user_match_added:#{user_id}")
      :ok
    end
  end

  def bulk_queue_events(users) do
    Enum.each(users, fn user ->
      %{
        user_id: user.id
      }
      |> __MODULE__.new()
      |> Oban.insert()
    end)
  end

  def calculate_average(match_participants, :win = field) do
    total_participants = length(match_participants)
    aggregate = Enum.reduce(match_participants, 0, fn match_participant, acc ->
      v = if match_participant[field], do: 1, else: 0
      acc + v
    end)
    aggregate / total_participants
  end

  def calculate_average(match_participants, field) do
    total_participants = length(match_participants)
    aggregate = Enum.reduce(match_participants, 0.0, fn match_participant, acc ->
      acc + match_participant[field]
    end)
    aggregate / total_participants
  end

  def calculate_update_params(match_participants) do
    %{
      avg_assists: calculate_average(match_participants, :assists),
      avg_baron_kills: calculate_average(match_participants, :baron_kills),
      avg_champ_experience: calculate_average(match_participants, :champ_experience),
      avg_champ_level: calculate_average(match_participants, :champ_level),
      avg_damage_dealt_to_buildings: calculate_average(match_participants, :damage_dealt_to_buildings),
      avg_damage_dealt_to_objectives: calculate_average(match_participants, :damage_dealt_to_objectives),
      avg_damage_dealt_to_turrets: calculate_average(match_participants, :damage_dealt_to_turrets),
      avg_damage_self_mitigated: calculate_average(match_participants, :damage_self_mitigated),
      avg_deaths: calculate_average(match_participants, :deaths),
      avg_gold_earned: calculate_average(match_participants, :gold_earned),
      avg_gold_spent: calculate_average(match_participants, :gold_spent),
      avg_kills: calculate_average(match_participants, :kills),
      avg_largest_killing_spree: calculate_average(match_participants, :largest_killing_spree),
      avg_largest_multi_kill: calculate_average(match_participants, :largest_multi_kill),
      avg_magic_damage_dealt: calculate_average(match_participants, :magic_damage_dealt),
      avg_magic_damage_dealt_to_champions: calculate_average(match_participants, :magic_damage_dealt_to_champions),
      avg_magic_damage_taken: calculate_average(match_participants, :magic_damage_taken),
      avg_physical_damage_dealt: calculate_average(match_participants, :physical_damage_dealt),
      avg_physical_damage_dealt_to_champions:
        calculate_average(match_participants, :physical_damage_dealt_to_champions),
      avg_physical_damage_taken: calculate_average(match_participants, :physical_damage_taken),
      avg_total_damage_dealt: calculate_average(match_participants, :total_damage_dealt),
      avg_total_damage_dealt_to_champions: calculate_average(match_participants, :total_damage_dealt_to_champions),
      avg_total_damage_taken: calculate_average(match_participants, :total_damage_taken),
      avg_total_heal: calculate_average(match_participants, :total_heal),
      avg_total_minions_killed: calculate_average(match_participants, :total_minions_killed),
      avg_total_time_spent_dead: calculate_average(match_participants, :total_time_spent_dead),
      avg_win: calculate_average(match_participants, :win),
    }
  end

  def update_user_match_aggregate(user_id) do
    with {:ok, user} <- Accounts.find_user(%{id: user_id}),
    {:ok, user_match_aggregate} <-
      League.find_or_create_user_match_aggregate(%{user_id: user_id}) do
      %{match_participants: match_participants} = League.preload_thirty_participants(user)
      update_params = match_participants
      |> Enum.map(& Map.from_struct(&1))
      |> calculate_update_params()
      League.update_user_match_aggregate(user_match_aggregate, update_params)
    end
  end
end
