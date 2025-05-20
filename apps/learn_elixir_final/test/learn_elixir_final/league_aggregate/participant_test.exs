defmodule LearnElixirFinal.LeagueAggregate.ParticipantTest do
  use ExUnit.Case
  alias LearnElixirFinal.LeagueAggregate.Participant
  alias LearnElixirFinalPg.League.MatchParticipant

  test "&aggregate_participants/1" do
    participants = [
      %MatchParticipant{
        id: 1,
        assists: 1,
        win: true
      },
      %MatchParticipant{
        id: 1,
        assists: 0,
        win: true
      },
      %MatchParticipant{
        id: 1,
        assists: 0,
        win: true
      },
      %MatchParticipant{
        id: 1,
        assists: 0,
        win: false
      },
    ]
    assert %{assists: 0.25, win: 0.75} === Participant.aggregate_participants(participants)
  end
end
