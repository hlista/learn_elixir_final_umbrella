defmodule LearnElixirFinal.LeagueAggregate.Participant do
  alias LearnElixirFinalPg.League.MatchParticipant
  def aggregate_participants(participants) do
    count = length(participants)
    participants
    |> Enum.reduce(%{}, fn participant, acc ->
      calculate_participant_totals(participant, acc)
    end)
    |> Enum.map(fn {k, v} ->
      {k, v / count}
    end)
    |> Enum.into(%{})
  end

  def calculate_participant_totals(%MatchParticipant{} = participant, acc) do
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
  end
end
