#!/usr/bin/env bash
set -e

cd /data

echo "Starting Playit..."
playit --secret "$SECRET_KEY" 2>&1 | tee /data/playit.log &
PLAYIT_PID=$!

echo "Starting Fabric Minecraft server..."
java \
  -Xms"${MIN_RAM:-2G}" \
  -Xmx"${MAX_RAM:-4G}" \
  -jar fabric-server.jar \
  nogui &
MINECRAFT_PID=$!

cleanup() {
    echo "Stopping services..."
    kill "$PLAYIT_PID" "$MINECRAFT_PID" 2>/dev/null || true
    wait || true
}

trap cleanup SIGTERM SIGINT

wait -n "$PLAYIT_PID" "$MINECRAFT_PID"
