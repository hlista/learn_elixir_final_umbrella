#!/bin/sh

echo "migrating database"
/app/bin/learn_elixir_final eval "LearnElixirFinal.Release.migrate"

/app/bin/learn_elixir_final start