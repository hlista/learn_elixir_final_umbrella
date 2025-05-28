#!/bin/sh

export RELEASE_NODE="learn_elixir_final@$(hostname)"

echo "migrating database"
/app/bin/learn_elixir_final eval "LearnElixirFinal.Release.migrate"

echo "Starting node as $RELEASE_NODE"
/app/bin/learn_elixir_final start