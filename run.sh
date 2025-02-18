#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="windsurf"

# Stop and remove existing container if running
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Stopping and removing existing container..."
    docker stop "${CONTAINER_NAME}" || true
    docker rm "${CONTAINER_NAME}" || true
fi

docker run --rm -it \
    --name "${CONTAINER_NAME}" \
    --shm-size=512m \
    -p 6901:6901 \
    -e VNC_PW=password \
    ghcr.io/drengskapur/kasmweb-windsurf:develop
