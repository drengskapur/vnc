variable "KASMWEB_IMAGE" {
    default = "kasmweb/desktop:develop"
}

variable "TAG" {
    default = ""
}

# Get Windsurf version from package
function "get_version" {
    params = []
    result = regex_replace(
        regex_replace(
            run("apt-cache show windsurf | grep Version | cut -d' ' -f2 | cut -d'-' -f1"),
            "\n",
            ""
        ),
        "\r",
        ""
    )
}

# Default target
group "default" {
    targets = ["windsurf"]
}

# Common settings
target "windsurf" {
    dockerfile = "Dockerfile"
    platforms = ["linux/amd64"]
    tags = [
        "windsurf:${TAG != "" ? TAG : get_version()}",
        "windsurf:latest"
    ]
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
