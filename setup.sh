#!/usr/bin/env bash
set -euo pipefail

# Create local bin directory if it doesn't exist
mkdir -p "$HOME/.local/bin"

# Install Task if not present
if ! command -v task &> /dev/null; then
    echo "Installing Task..."
    sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin

    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi
fi

# Install direnv - manage environment variables per directory
# docs: https://direnv.net/
task install-direnv
