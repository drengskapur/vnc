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

### Testing GitHub Actions

You can test the CI workflow locally using [act](https://github.com/nektos/act). Install it first:

```bash
# macOS
brew install act

# Linux
curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
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
