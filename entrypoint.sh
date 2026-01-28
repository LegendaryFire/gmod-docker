#!/bin/sh
set -euo pipefail

ls -lha /data

# Create defaults, only if missing. Then link the server.cfg and users.txt to their corresponding paths.
[ -f /data/config/server.cfg ] || cp /data/defaults/server.cfg /data/config/server.cfg
[ -f /data/config/users.txt  ] || cp /data/defaults/users.txt  /data/config/users.txt
ln -sf /data/config/server.cfg /data/garrysmod/cfg/server.cfg
ln -sf /data/config/users.txt  /data/garrysmod/settings/users.txt

# Set default environment variable values.
PORT="${PORT:-27015}"
GAMEMODE="${GAMEMODE:-terrortown}"
GSLT="${GSLT:-}"
ARGS="${ARGS:-}"

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
