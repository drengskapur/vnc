#!/usr/bin/env bash
set -euo pipefail

# Create builder instance if it doesn't exist
BUILDER="windsurf-builder"
if ! docker buildx inspect "$BUILDER" >/dev/null 2>&1; then
    docker buildx create --name "$BUILDER" --driver docker-container --bootstrap
fi

# Use the builder
docker buildx use "$BUILDER"

# Check if --test flag is provided
if [[ "${1:-}" == "--test" ]]; then
    # Test workflow using act
    act push -W .github/workflows/ci.yml
else
    # Execute build
    docker buildx bake -f docker-bake.hcl --load develop
fi
