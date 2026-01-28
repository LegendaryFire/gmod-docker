#!/bin/sh
set -eu

PORT="${PORT:-27015}"
GAMEMODE="${GAMEMODE:-terrortown}"
ARGS="${ARGS:-}"
GSLT="${GSLT:-}"

if [ "$#" -gt 0 ]; then  # Passing args directly to docker run.
  exec /data/srcds_run \
    -game garrysmod \
    -console \
    "$@"
else  # Passing args with an environment variable.
  exec /data/srcds_run \
    -game garrysmod \
    -console \
    -port "${PORT}" \
    +gamemode "${GAMEMODE}" \
    +sv_setsteamaccount "${GSLT}" \
    +exec server.cfg \
    "${ARGS}"
fi
