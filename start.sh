#!/usr/bin/env bash
set -euo pipefail

cd /data

if [ -z "${SECRET_KEY:-}" ]; then
    echo "ERROR: SECRET_KEY is missing."
    exit 1
fi

echo "Starting Playit..."
playit 2>&1 | tee /data/playit.log &
PLAYIT_PID=$!

echo "Starting Fabric Minecraft server..."
java \
  -Xms"${MIN_RAM:-2G}" \
  -Xmx"${MAX_RAM:-4G}" \
  -jar fabric-server.jar \
  nogui &
MC_PID=$!

cleanup() {
    echo "Stopping services..."
    kill "$PLAYIT_PID" "$MC_PID" 2>/dev/null || true
    wait || true
}

trap cleanup SIGINT SIGTERM

wait "$MC_PID"
