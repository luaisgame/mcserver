#!/usr/bin/env bash
set -e

cd /data

echo "Starting Playit..."
playit --secret "$SECRET_KEY" 2>&1 | tee /data/playit.log &
PLAYIT_PID=$!
