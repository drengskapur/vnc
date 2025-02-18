#!/usr/bin/env bash
set -euo pipefail

# Create builder instance if it doesn't exist
BUILDER="windsurf-builder"
if ! docker buildx inspect "$BUILDER" >/dev/null 2>&1; then
    docker buildx create --name "$BUILDER" --driver docker-container --bootstrap
fi

# Use the builder
docker buildx use "$BUILDER"

# Execute build
docker buildx bake -f docker-bake.hcl --load develop
