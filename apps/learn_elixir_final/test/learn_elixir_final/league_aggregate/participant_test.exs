defmodule LearnElixirFinal.LeagueAggregate.ParticipantTest do
  use ExUnit.Case
  alias LearnElixirFinal.LeagueAggregate.Participant
  alias LearnElixirFinalPg.League.MatchParticipant

  test "&aggregate_participants/1" do
    participants = [
      %MatchParticipant{
        id: 1,
        assists: 2,
        win: true
      },
      %MatchParticipant{
        id: 1,
        assists: 2,
        win: true
      },
      %MatchParticipant{
        id: 1,
        assists: 2,
        win: true
      },
      %MatchParticipant{
        id: 1,
        assists: 2,
        win: false
      },
    ]
    assert %{assists: 2.0, win: 0.75} === Participant.aggregate_participants(participants)
  end
end
