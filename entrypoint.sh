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

is_missing_or_empty() {
  [ $# -ge 1 ] || return 0
  [ -e "$1" ] || return 0
  [ -f "$1" ] || return 1
  grep -q '[^[:space:]]' -- "$1" && return 1
  return 0
}

DEFAULT_SERVER_CFG="/data/defaults/server.cfg"
if is_missing_or_empty "/data/garrysmod/cfg/server.cfg"; then
  warn "The server.cfg file is missing or empty. Populating with image defaults."
  cp "$DEFAULT_SERVER_CFG" "/data/garrysmod/cfg/server.cfg"
else
  echo "Using existing server.cfg file."
fi

CACHE_DIR="/data/garrysmod/cache"
# Validate correct file permissions for the workshop cache directory.
if ! has_permission "$CACHE_DIR"; then
  error "Insufficient permissions to cache directory $CACHE_DIR. Exiting."
  sleep 5
  exit 1
fi

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
