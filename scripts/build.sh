#!/usr/bin/env bash
set -euo pipefail

# Get project root directory (parent of scripts directory)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Script configuration
REGISTRY="${REGISTRY:-ghcr.io}"
REPOSITORY="${REPOSITORY:-drengskapur/kasmweb-windsurf}"
PLATFORMS="${PLATFORMS:-linux/amd64}"
COMMAND="${COMMAND:-dev}"  # Set dev as default command

# Logging functions
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >&2
}

error() {
    log "ERROR: $*"
    exit 1
}

# Help message
show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] [COMMAND]

Build Windsurf Docker images using docker buildx bake.

Commands:
    dev         Build development image with local caching (default)
    prod        Build production image with registry caching
    help        Show this help message

Options:
    -t, --tag TAG           Override the auto-detected version tag
    -p, --push             Push images to registry
    -r, --registry URL     Container registry URL (default: ${REGISTRY})
    --platforms PLATFORMS  Target platforms (default: ${PLATFORMS})
    -h, --help            Show this help message

Environment variables:
    REGISTRY    Container registry URL
    REPOSITORY  Container repository name
    PLATFORMS   Target platforms (comma-separated)
    TAG         Override version tag
    COMMAND     Build command (dev or prod)

Examples:
    # Default development build
    $(basename "$0")

    # Production build and push to registry
    $(basename "$0") -p prod

    # Build with custom tag
    $(basename "$0") -t v1.3.4

    # Build for multiple platforms
    $(basename "$0") --platforms "linux/amd64,linux/arm64" prod
EOF
}

# Parse arguments
PUSH=false
TAG=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        dev|prod|help)
            COMMAND="$1"
            shift
            ;;
        -t|--tag)
            TAG="$2"
            shift 2
            ;;
        -p|--push)
            PUSH=true
            shift
            ;;
        -r|--registry)
            REGISTRY="$2"
            shift 2
            ;;
        --platforms)
            PLATFORMS="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            error "Unknown argument: $1"
            ;;
    esac
done

# Show help if requested
if [[ "$COMMAND" == "help" ]]; then
    show_help
    exit 0
fi

# Ensure docker buildx is available
if ! docker buildx version >/dev/null 2>&1; then
    error "docker buildx is not available"
fi

# Create builder instance if it doesn't exist
BUILDER="windsurf-builder"
if ! docker buildx inspect "$BUILDER" >/dev/null 2>&1; then
    log "Creating new builder instance: $BUILDER"
    docker buildx create --name "$BUILDER" --driver docker-container --bootstrap
fi

# Use the builder
docker buildx use "$BUILDER"

# Prepare build arguments
ARGS=()

# Add tag if specified
if [[ -n "$TAG" ]]; then
    ARGS+=(--set "*.tags=${REGISTRY}/${REPOSITORY}:${TAG}")
fi

# Add platforms
ARGS+=(--set "*.platform=${PLATFORMS}")

# Configure output based on push flag
if [[ "$PUSH" == "true" ]]; then
    ARGS+=(--push)
else
    ARGS+=(--load)
fi

# Execute build
log "Building Windsurf image (${COMMAND})"
if [[ "$COMMAND" == "dev" ]]; then
    docker buildx bake -f "${PROJECT_ROOT}/docker-bake.hcl" "${ARGS[@]}" dev
else
    docker buildx bake -f "${PROJECT_ROOT}/docker-bake.hcl" "${ARGS[@]}" prod
fi

log "Build completed successfully"
