variable "REGISTRY" {
    default = "ghcr.io/drengskapur"
}

variable "REPOSITORY" {
    default = "kasmweb-windsurf"
}

variable "KASMWEB_IMAGE" {
    default = "kasmweb/desktop:develop"
}

variable "KASMVNC_VERSION" {
    default = "1.3.3"
}

variable "VERSION" {
    default = "develop"
}

variable "TAGS" {
    default = [
        "${REGISTRY}/${REPOSITORY}:${VERSION}",
        "${REGISTRY}/${REPOSITORY}:develop"
    ]
}

# Default target
group "default" {
    targets = ["windsurf"]
}

# Common settings
target "windsurf" {
    dockerfile = "Dockerfile"
    platforms = ["linux/amd64"]
    tags = TAGS
    args = {
        KASMWEB_IMAGE = "${KASMWEB_IMAGE}"
        KASMVNC_VERSION = "${KASMVNC_VERSION}"
    }
}

# Development build
target "dev" {
    inherits = ["windsurf"]
    output = ["type=docker"]
}

# Production build
target "prod" {
    inherits = ["windsurf"]
    output = ["type=registry"]
}
