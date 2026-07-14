#!/usr/bin/env bash
set -euo pipefail

cd /data

if [ -z "${SECRET_KEY:-}" ]; then
    echo "ERROR: SECRET_KEY is not configured."
    exit 1
fi

MAX_RAM="${MAX_RAM:-3G}"
MIN_RAM="${MIN_RAM:-1G}"

echo "eula=true" > eula.txt
mkdir -p mods

if [ ! -f server.properties ]; then
    cat > server.properties <<'EOF'
server-ip=
allow-flight=true
online-mode=false
enforce-secure-profile=false
white-list=false
view-distance=6
simulation-distance=4
spawn-protection=1
EOF
fi

echo "Starting Playit agent..."
playit --secret "$SECRET_KEY" 2>&1 | tee /data/playit.log &
PLAYIT_PID=$!

echo "Starting Fabric Minecraft servers..."
java -Xms"$MIN_RAM" -Xmx"$MAX_RAM" -jar fabric-server.jar nogui &
MINECRAFT_PID=$!

cleanup() {
    echo "Stopping services..."
    kill "$PLAYIT_PID" "$MINECRAFT_PID" 2>/dev/null || true
    wait || true
}

trap cleanup SIGTERM SIGINT

wait -n "$PLAYIT_PID" "$MINECRAFT_PID"
EXIT_CODE=$?

cleanup
exit "$EXIT_CODE"
