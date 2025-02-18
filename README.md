# KasmVNC Windsurf Docker Image

Containerized Ubuntu Desktop with Windsurf IDE and KasmVNC for Browser Access.

- Windsurf IDE in a containerized environment
- KasmVNC for remote access
- i3 window manager for keyboard navigation
- Automatic window maximization
- Configurable display settings

## Run

```bash
docker run --rm -it --shm-size=512m -p 6901:6901 -e VNC_PW=password ghcr.io/drengskapur/kasmweb-windsurf:develop
```

The container is accessible via a browser at: `https://IP_OF_SERVER:6901`

**Access Credentials:**
- Username: `kasm_user`
- Password: `password`
