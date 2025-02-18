variable "KASMWEB_IMAGE" {
    default = "kasmweb/desktop:develop"
}

variable "TAGS" {
    default = ["windsurf:latest"]
}

# Default target
group "default" {
    targets = ["windsurf"]
}

# Common settings
target "windsurf" {
    dockerfile = "Dockerfile"
    platforms = ["linux/amd64"]
    tags = "${TAGS}"
    args = {
        KASMWEB_IMAGE = "${KASMWEB_IMAGE}"
    }
}

# Development build with caching enabled
target "dev" {
    inherits = ["windsurf"]
    cache-from = ["type=local,src=/tmp/.buildx-cache"]
    cache-to = ["type=local,dest=/tmp/.buildx-cache"]
    output = ["type=docker"]
}

# Production build with registry caching
target "prod" {
    inherits = ["windsurf"]
    cache-from = ["type=registry,ref=windsurf:cache"]
    cache-to = ["type=registry,ref=windsurf:cache,mode=max"]
    output = ["type=registry"]
}
