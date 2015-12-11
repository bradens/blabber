#! /bin/bash
export MIX_ENV=prod
export PORT=80
mix compile.protocols
elixir -pa _build/prod/consolidated --detached -S mix phoenix.server > /home/ubuntu/blabber/blabber.log
