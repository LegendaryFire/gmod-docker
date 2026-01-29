#!/bin/sh
set -euo pipefail

warn() {
  if [ -t 2 ]; then
    printf '\e[1;33mWARNING:\e[0m %s\n' "$*" >&2
  else
    printf 'WARNING: %s\n' "$*" >&2
  fi
}

error() {
  if [ -t 2 ]; then
    printf '\e[1;31mERROR:\e[0m %s\n' "$*" >&2
  else
    printf 'ERROR: %s\n' "$*" >&2
  fi
}

has_permission() {
  [ -d "$1" ] && [ -w "$1" ] && [ -x "$1" ]
}

DEFAULT_DIR="/data/defaults"
CONFIG_DIR="/data/config"
CACHE_DIR="/data/garrysmod/cache"

# Validate correct file permissions for the config and cache directories.
if ! has_permission "$CONFIG_DIR"; then
  error "Insufficient permissions to configuration directory $CONFIG_DIR. Exiting."
  sleep 5
  exit 1
fi

if ! has_permission "$CACHE_DIR"; then
  error "Insufficient permissions to cache directory $CACHE_DIR. Exiting."
  sleep 5
  exit 1
fi

# Create defaults, only if missing. Then link the server.cfg and users.txt to their corresponding paths.
[ -f "$CONFIG_DIR/server.cfg" ] || cp "$DEFAULT_DIR/server.cfg" "$CONFIG_DIR/server.cfg"
[ -f "$CONFIG_DIR/users.txt"  ] || cp "$DEFAULT_DIR/users.txt"  "$CONFIG_DIR/users.txt"
ln -sf "$CONFIG_DIR/server.cfg" /data/garrysmod/cfg/server.cfg
ln -sf "$CONFIG_DIR/users.txt"  /data/garrysmod/settings/users.txt

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
