defmodule LearnElixirFinal.LeagueAggregate.ParticipantTest do
  use ExUnit.Case
  alias LearnElixirFinal.LeagueAggregate.Participant
  alias LearnElixirFinalPg.League.MatchParticipant

  test "&aggregate_participants/1" do
    participants = [
      %MatchParticipant{
        id: 1,
        assists: 2
      },
      %MatchParticipant{
        id: 1,
        assists: 2
      },
      %MatchParticipant{
        id: 1,
        assists: 2
      },
    ]
    assert %{assists: 2.0} === Participant.aggregate_participants(participants)
  end
end
