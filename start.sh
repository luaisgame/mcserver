#!/usr/bin/env bash
set -e

echo "Playit version:"
playit --version || playit --help

echo "Container is alive."

tail -f /dev/null
