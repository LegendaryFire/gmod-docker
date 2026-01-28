#!/bin/sh
set -eu

if [ "$#" -gt 0 ]; then  # Passing args directly to docker run.
  exec /data/srcds_run -game garrysmod -console "$@"
else  # Passing args with an environment variable.
  exec sh -c "/data/srcds_run -game garrysmod -console -port $GMOD_PORT $GMOD_ARGS"
fi
