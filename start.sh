#!/usr/bin/env bash
set -euo pipefail

cd /data

if [ -z "${SECRET_KEY:-}" ]; then
    echo "ERROR: SECRET_KEY is not configured."
    exit 1
fi

# Download Paper if server.jar does not exist.
if [ ! -f server.jar ]; then
    if [ -z "${SERVER_JAR_URL:-}" ]; then
        echo "ERROR: Add SERVER_JAR_URL or upload server.jar to /data."
        exit 1
    fi

    echo "Downloading Minecraft server..."
    curl -L "$SERVER_JAR_URL" -o server.jar
fi

echo "eula=true" > eula.txt

# Never bind server-ip to a Render hostname.
if [ ! -f server.properties ]; then
    cat > server.properties <<'EOF'
server-ip=
server-port=25565
online-mode=true
white-list=true
motd=Minecraft server hosted on Render
view-distance=8
simulation-distance=6
EOF
fi

echo "Starting Playit agent..."
playit > /data/playit.log 2>&1 &
PLAYIT_PID=$!

echo "Starting Minecraft..."
java \
    -Xms"${MIN_RAM:-1G}" \
    -Xmx"${MAX_RAM:-4G}" \
    -jar server.jar nogui &
MINECRAFT_PID=$!

cleanup() {
    echo "Stopping services..."
    kill "$PLAYIT_PID" "$MINECRAFT_PID" 2>/dev/null || true
    wait || true
}

trap cleanup SIGTERM SIGINT

# Stop the container if either process crashes.
wait -n "$PLAYIT_PID" "$MINECRAFT_PID"
EXIT_CODE=$?

cleanup
exit "$EXIT_CODE"
