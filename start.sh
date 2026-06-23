#!/usr/bin/env bash
set -euo pipefail

cd /data

if [ -z "${SECRET_KEY:-}" ]; then
    echo "ERROR: SECRET_KEY is not configured."
    exit 1
fi

MC_VERSION="${MC_VERSION:-1.21.11}"
FABRIC_INSTALLER_VERSION="${FABRIC_INSTALLER_VERSION:-1.0.1}"
MAX_RAM="${MAX_RAM:-36G}"
MIN_RAM="${MIN_RAM:-8G}"

echo "eula=true" > eula.txt

mkdir -p mods

if [ ! -f fabric-server-launch.jar ]; then
    echo "Downloading Fabric installer..."

    curl -L \
        "https://maven.fabricmc.net/net/fabricmc/fabric-installer/${FABRIC_INSTALLER_VERSION}/fabric-installer-${FABRIC_INSTALLER_VERSION}.jar" \
        -o fabric-installer.jar

    echo "Installing Fabric server..."

    java -jar fabric-installer.jar \
        server \
        -mcversion "$MC_VERSION" \
        -downloadMinecraft
fi

if [ ! -f server.properties ]; then
    cat > server.properties <<'EOF'
server-ip=
server-port=25565
online-mode=false
enforce-secure-profile=false
white-list=false
motd=SMP ig
view-distance=6
simulation-distance=4
EOF
fi

# Auto-op Enzoe1522 every startup
cat > ops.json <<'EOF'
[
  {
    "uuid": "",
    "name": "Enzoe1522",
    "level": 4,
    "bypassesPlayerLimit": true
  }
]
EOF

echo "Starting Playit agent..."
playit --secret "$SECRET_KEY" 2>&1 | tee /data/playit.log &
PLAYIT_PID=$!

echo "Starting Fabric Minecraft server..."
java \
    -Xms"$MIN_RAM" \
    -Xmx"$MAX_RAM" \
    -jar fabric-server-launch.jar \
    nogui &
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
