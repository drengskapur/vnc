# =========================================================================== #
# DOCKER BAKE FILE
# Configuration file for Docker Buildx Bake
#
# This file defines the build configuration for the kasmweb-windsurf container.
# It supports both local development builds and CI/CD pipeline builds.
# =========================================================================== #

# --------------------------------------------------------------------------- #
# COMMON VARIABLES
# These variables control the build process and image configuration
# --------------------------------------------------------------------------- #

# Registry configuration
variable "REGISTRY" {
    default = "ghcr.io"  # GitHub Container Registry
}

variable "OWNER" {
    default = "drengskapur"  # Repository owner
}

variable "IMAGE" {
    default = "kasmweb-windsurf"  # Image name
}

variable "TAG" {
    default = "develop"  # Default tag for development builds
}

# Base image configuration
variable "BASE_IMAGE" {
    default = "kasmweb/desktop:1.16.1"  # KasmVNC base image
}

# Build cache configuration
variable "CACHE_DIR" {
    default = ".buildx-cache"  # Local directory for build cache
}

variable "CACHE_MODE" {
    default = "max"  # Cache mode options: "max" (most aggressive), "min" (minimal), "inline" (embedded)
}

# Build behavior control
variable "push" {
    default = false  # Set to true to push to registry, false for local builds
}

# --------------------------------------------------------------------------- #
# SETTINGS
# Common build settings inherited by all targets
# --------------------------------------------------------------------------- #
target "settings" {
    context = "."
    platforms = ["linux/amd64"]  # x86_64 platform support
    
    # Use host network for better performance
    network = "host"
}

# --------------------------------------------------------------------------- #
# Main development build
# Primary build target for the windsurf container
# --------------------------------------------------------------------------- #
target "develop" {
    inherits = ["settings"]  # Inherit common settings
    dockerfile = "Dockerfile"
    
    # Tag configuration
    tags = [
        "${REGISTRY}/${OWNER}/${IMAGE}:${TAG}",
        "${REGISTRY}/${OWNER}/${IMAGE}:latest"
    ]
    
    # Build arguments
    args = {
        BASE_IMAGE = "${BASE_IMAGE}"
    }

    # Push configuration
    push = "${push}"
}

# Default group - what gets built when no target is specified
group "default" {
    targets = ["develop"]
}
