# KasmVNC Windsurf Docker Image

Containerized Ubuntu Desktop with Windsurf IDE and KasmVNC for Browser Access.

- Windsurf IDE in a containerized environment
- KasmVNC for remote access
- i3 window manager for keyboard navigation
- Automatic window maximization
- Configurable display settings

## Build

```bash
# Normal build
./build.sh

# Test GitHub Actions workflow locally
./build.sh --test
```

## Run

```bash
docker run --rm -it --shm-size=512m -p 6901:6901 -e VNC_PW=password ghcr.io/drengskapur/kasmweb-windsurf:develop
```

The container is accessible via a browser at: `https://IP_OF_SERVER:6901`

**Access Credentials:**
- Username: `kasm_user`
- Password: `password`

## Local Development

### Setup

Run the setup script to install development tools:

```bash
./setup.sh
```

This will install:
- Task (taskfile.dev) for build automation

### Testing GitHub Actions

The script will automatically install `act` in `$HOME/.local/bin` if it's not found. You can also install it manually:

```bash
# macOS
brew install act

# Linux
mkdir -p "$HOME/.local/bin"
curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | bash -s -- -b "$HOME/.local/bin"
```

Then run the workflow test:
```bash
./build.sh --test
```

You can also create a `.env` file to provide environment variables for local testing:

```bash
# .env example
OWNER=myorg
TAG=test
```

The `.env` file will be automatically loaded when running `./build.sh --test`.
