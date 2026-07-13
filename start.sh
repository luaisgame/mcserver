#!/usr/bin/env bash
set -e

cd /data

echo "Starting Playit Agent..."
/usr/local/bin/playit-agent &
PLAYIT_PID=$!

echo "Starting Minecraft..."
java \
  -Xms"${MIN_RAM:-32G}" \
  -Xmx"${MAX_RAM:-12G}" \
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
