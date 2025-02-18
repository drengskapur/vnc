#!/usr/bin/env bash
set -euo pipefail

# Install act if not present (Ubuntu)
if ! command -v act &> /dev/null; then
    echo "Installing act..."
    curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
fi

# Create builder instance if it doesn't exist
BUILDER="windsurf-builder"
if ! docker buildx inspect "$BUILDER" >/dev/null 2>&1; then
    docker buildx create --name "$BUILDER" --driver docker-container --bootstrap
fi

# Use the builder
docker buildx use "$BUILDER"

# Check if --test flag is provided
if [[ "${1:-}" == "--test" ]]; then
    # Test workflow using act with optional environment variables
    if [[ -f .env ]]; then
        act push -W .github/workflows/ci.yml --env-file .env
    else
        act push -W .github/workflows/ci.yml
    fi
else
    # Execute build
    docker buildx bake -f docker-bake.hcl --load develop
fi
