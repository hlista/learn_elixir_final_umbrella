defmodule LearnElixirFinal.LeagueAggregate.AggregateMatches do
  def aggregate_matches(matches) do
    matches
  end

  def aggregate_match_participants(participants) do
    count = length(participants)
    participants
    |> Enum.reduce(%{}, fn participant, acc ->
      participant
      |> Map.from_struct()
      |> Enum.map(fn
        {:id, _} -> {}
        {k, v} when is_integer(v) ->
          current_value = Map.get(acc, k, 0)
          {k, current_value + v}
        {k, true} ->
          current_value = Map.get(acc, k, 0)
          {k, current_value + 1}
        _ -> {}
      end)
      |> Enum.reject(&(&1 === {}))
      |> Enum.into(%{})
    end)
    |> Enum.map(fn {k, v} ->
      {k, v / count}
    end)
    |> Enum.into(%{})
  end
end

  # field :assists, :integer
  #   field :baron_kills, :integer
  #   field :champ_experience, :integer
  #   field :champ_level, :integer
  #   field :champion_name, :string
  #   field :damage_dealt_to_buildings, :integer
  #   field :damage_dealt_to_objectives, :integer
  #   field :damage_dealt_to_turrets, :integer
  #   field :damage_self_mitigated, :integer
  #   field :deaths, :integer
  #   field :gold_earned, :integer
  #   field :gold_spent, :integer
  #   field :kills, :integer
  #   field :largest_killing_spree, :integer
  #   field :largest_multi_kill, :integer
  #   field :magic_damage_dealt, :integer
  #   field :magic_damage_dealt_to_champions, :integer
  #   field :magic_damage_taken, :integer
  #   field :physical_damage_dealt, :integer
  #   field :physical_damage_dealt_to_champions, :integer
  #   field :physical_damage_taken, :integer
  #   field :total_damage_dealt, :integer
  #   field :total_damage_dealt_to_champions, :integer
  #   field :total_damage_taken, :integer
  #   field :total_heal, :integer
  #   field :total_minions_killed, :integer
  #   field :total_time_spent_dead, :integer
  #   field :win, :boolean
