// Common variables
variable "REGISTRY" {
    default = "ghcr.io"
}

variable "OWNER" {
    default = "drengskapur"
}

variable "IMAGE" {
    default = "kasmweb-windsurf"
}

variable "TAG" {
    default = "develop"
}

variable "BASE_IMAGE" {
    default = "kasmweb/desktop:1.16.1"
}

variable "CACHE_DIR" {
    default = ".buildx-cache"
}

variable "CACHE_MODE" {
    default = "max"  // Can be: "max", "min", or "inline"
}

variable "PUSH_IMAGE" {
    default = "false"
}

# Special target for build settings
target "settings" {
    context = "."
    platforms = ["linux/amd64"]
    cache-from = ["type=local,src=${CACHE_DIR}"]
    cache-to = ["type=local,dest=${CACHE_DIR},mode=${CACHE_MODE}"]
    output = ["type=docker"]
    no-cache-filter = ["fetch-deps"]
    network = "host"
}

# Default group
group "default" {
    targets = ["develop"]
}

# Main development build
target "develop" {
    inherits = ["settings"]
    dockerfile = "Dockerfile"
    tags = [
        "${REGISTRY}/${OWNER}/${IMAGE}:${TAG}",
        "${REGISTRY}/${OWNER}/${IMAGE}:latest"
    ]
    args = {
        BASE_IMAGE = "${BASE_IMAGE}"
    }
    output = PUSH_IMAGE == "true" ? ["type=registry"] : ["type=docker"]
}
