defmodule LearnElixirFinal.PuuidPipeline.LeagueAccountProducterTest do
  use LearnElixirFinal.DataCase, async: false
  alias LearnElixirFinal.PuuidPipeline.LeagueAccountProducer

  test "is_current_node_responsible" do
    assert LeagueAccountProducer.is_current_node_responsible(%{id: "123"})
  end
end
