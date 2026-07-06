#!/usr/bin/env bash
set -euo pipefail

cd /data

echo "Starting Fabric Minecraft server..."
java \
  -Xms"${MIN_RAM:-1G}" \
  -Xmx"${MAX_RAM:-4G}" \
  -jar fabric-server-launch.jar \
  nogui
