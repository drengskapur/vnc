# syntax=docker/dockerfile:1
ARG BASE_IMAGE=kasmweb/desktop:1.16.1
FROM ${BASE_IMAGE} AS base

USER root

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    # INSTALL DEPENDENCIES
    apt-get update && \
    apt-get install -y \
        curl \
        gpg \
        unzip && \
    # INSTALL WINDSURF
    curl -fsSL "https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/windsurf.gpg" | \
        gpg --dearmor -o /usr/share/keyrings/windsurf-stable-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/windsurf-stable-archive-keyring.gpg arch=amd64] https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/apt stable main" | \
        tee /etc/apt/sources.list.d/windsurf.list > /dev/null && \
    apt-get update && \
    apt-get install -y windsurf && \
    # CLEANUP
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER 1000
