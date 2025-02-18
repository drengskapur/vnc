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

# Function to get build timestamp
function "timestamp" {
    params = []
    result = formatdate("YYYY-MM-DD'T'hh:mm:ssZ", timestamp())
}

# Common metadata for all targets
variable "METADATA" {
    default = {
        "org.opencontainers.image.created" = "${timestamp()}"
        "org.opencontainers.image.source"  = "https://github.com/drengskapur/docker-kasmweb-windsurf"
        "org.opencontainers.image.version" = "${TAG}"
    }
}

# Default target
group "default" {
    targets = ["develop"]
}

# Main development build
target "develop" {
    dockerfile = "Dockerfile"
    platforms = ["linux/amd64"]
    tags = [
        "${REGISTRY}/${OWNER}/${IMAGE}:${TAG}",
        "${REGISTRY}/${OWNER}/${IMAGE}:latest"
    ]
    args = {
        BASE_IMAGE = "${BASE_IMAGE}"
    }
}
