#!/usr/bin/env bash
set -Eeuo pipefail

DATA_DIR="${DATA_DIR:-/data}"
MAX_RAM="${MAX_RAM:-3G}"
MIN_RAM="${MIN_RAM:-1G}"

if [[ -z "${SECRET_KEY:-}" ]]; then
    echo "ERROR: SECRET_KEY is not configured." >&2
    exit 1
fi

declare -a PIDS=()
CLEANED_UP=false

cleanup() {
    local exit_code=$?

    if [[ "$CLEANED_UP" == true ]]; then
        return
    fi
    CLEANED_UP=true

    trap - EXIT SIGINT SIGTERM
    echo "Stopping services..."

    if ((${#PIDS[@]})); then
        kill "${PIDS[@]}" 2>/dev/null || true
        wait "${PIDS[@]}" 2>/dev/null || true
    fi

    exit "$exit_code"
}

trap cleanup EXIT SIGINT SIGTERM

configure_server() {
    local server_dir=$1

    mkdir -p "$server_dir/mods"
    printf 'eula=true\n' > "$server_dir/eula.txt"

    if [[ ! -f "$server_dir/server.properties" ]]; then
        cat > "$server_dir/server.properties" <<'EOF'
server-ip=
allow-flight=true
online-mode=false
enforce-secure-profile=false
white-list=false
view-distance=6
simulation-distance=4
spawn-protection=0
EOF
    fi
}

start_minecraft() {
    local server_dir=$1
    local server_jar=$2
    local server_name=$3

    if [[ ! -f "$server_dir/$server_jar" ]]; then
        echo "ERROR: Missing $server_dir/$server_jar" >&2
        exit 1
    fi

    configure_server "$server_dir"

    echo "Starting $server_name..."
    (
        cd "$server_dir"
        exec java \
            -Xms"$MIN_RAM" \
            -Xmx"$MAX_RAM" \
            -jar "$server_jar" \
            nogui
    ) &

    PIDS+=("$!")
}

mkdir -p "$DATA_DIR"

echo "Starting Playit agent..."
playit --secret "$SECRET_KEY" \
    > >(tee "$DATA_DIR/playit.log") \
    2>&1 &
PIDS+=("$!")

start_minecraft "$DATA_DIR/mc1" "fabric-server.jar" "Fabric server"
start_minecraft "$DATA_DIR/mc2" "forge-server.jar" "Forge server"

echo "All services started."

# Shut everything down if any managed process exits.
set +e
wait -n "${PIDS[@]}"
EXIT_CODE=$?
set -e

echo "A service exited with status $EXIT_CODE."
exit "$EXIT_CODE"
