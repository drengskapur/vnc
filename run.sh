#!/usr/bin/env bash
set -euo pipefail

docker run --rm -it --shm-size=512m -p 6901:6901 ghcr.io/drengskapur/kasmweb-windsurf:develop
