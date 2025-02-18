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
