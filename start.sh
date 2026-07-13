#!/usr/bin/env bash
set -e

cd /data

echo "Starting Playit..."
playit --secret "$SECRET_KEY" &
PLAYIT_PID=$!

echo "Starting Fabric Minecraft server..."
java \
  -Xms"${MIN_RAM:-2G}" \
  -Xmx"${MAX_RAM:-4G}" \
  -jar fabric-server.jar \
  nogui &
MC_PID=$!

cleanup() {
    echo "Stopping..."
    kill "$PLAYIT_PID" "$MC_PID" 2>/dev/null || true
    wait || true
}

trap cleanup SIGINT SIGTERM

wait "$MC_PID"
