# syntax=docker/dockerfile:1
ARG KASMVNC_VERSION=1.3.3
ARG BASE_IMAGE=ubuntu:22.04

# Base stage with shared environment
FROM ubuntu:22.04@sha256:77906da86b60585ce12215807090eb327e7386c8fafb5402369e421f44eff17e AS base

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install base certificates for HTTPS
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    locales \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    DISPLAY=:1 \
    HOME=/home/windsurf \
    KASMVNC_PATH=/usr/local/share/kasmvnc \
    VNC_PORT=6901 \
    VNC_RESOLUTION=1920x1080 \
    VNC_DPI=96 \
    STARTUPDIR=/opt/windsurf/startup \
    MAXIMIZE=true \
    MAXIMIZE_NAME="Windsurf" \
    START_COMMAND="/usr/bin/windsurf" \
    PGREP="windsurf" \
    MAXIMIZE_SCRIPT=/opt/windsurf/startup/maximize_window.sh \
    DEFAULT_ARGS=""

# Create non-root user
RUN groupadd -g 1000 windsurf && \
    useradd -m -s /bin/bash -u 1000 -g windsurf windsurf && \
    usermod -aG sudo windsurf

# Install runtime dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    curl \
    dbus \
    dbus-x11 \
    i3 \
    i3status \
    pulseaudio \
    supervisor \
    xterm \
    && rm -rf /var/lib/apt/lists/*

# Install KasmVNC
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    wget \
    libnss3 \
    libxcomposite1 \
    libxdamage1 \
    libxtst6 \
    libasound2 \
    libfontconfig1 \
    libxkbcommon0 \
    libxrandr2 \
    libxcursor1 \
    libpulse0 \
    libgbm1 \
    libegl1 \
    xauth \
    x11-utils && \
    wget -q "https://github.com/kasmtech/KasmVNC/releases/download/v${KASMVNC_VERSION}/kasmvncserver_jammy_${KASMVNC_VERSION}_amd64.deb" -O kasmvnc.deb && \
    apt-get install -y --no-install-recommends ./kasmvnc.deb && \
    rm kasmvnc.deb && \
    rm -rf /var/lib/apt/lists/*

# Create required directories
RUN mkdir -p "${HOME}/.config/i3" \
    "${HOME}/.config/i3status" \
    "${STARTUPDIR}" && \
    chown -R windsurf:windsurf "${HOME}" "${STARTUPDIR}"

# Add i3 config
COPY <<EOF ${HOME}/.config/i3/config
# i3 config file (v4)
set $mod Mod4

# Font for window titles
font pango:DejaVu Sans Mono 10

# Use Mouse+$mod to drag floating windows
floating_modifier $mod

# Start a terminal
bindsym $mod+Return exec xterm

# Kill focused window
bindsym $mod+Shift+q kill

# Change focus
bindsym $mod+j focus left
bindsym $mod+k focus down
bindsym $mod+l focus up
bindsym $mod+semicolon focus right

# Move focused window
bindsym $mod+Shift+j move left
bindsym $mod+Shift+k move down
bindsym $mod+Shift+l move up
bindsym $mod+Shift+semicolon move right

# Split in horizontal orientation
bindsym $mod+h split h

# Split in vertical orientation
bindsym $mod+v split v

# Enter fullscreen mode
bindsym $mod+f fullscreen toggle

# Change container layout
bindsym $mod+s layout stacking
bindsym $mod+w layout tabbed
bindsym $mod+e layout toggle split

# Toggle tiling / floating
bindsym $mod+Shift+space floating toggle

# Change focus between tiling / floating windows
bindsym $mod+space focus mode_toggle

# Focus the parent container
bindsym $mod+a focus parent

# Define names for workspaces
set $ws1 "1: Terminal"
set $ws2 "2: Editor"
set $ws3 "3: Browser"
set $ws4 "4: Tools"

# Switch to workspace
bindsym $mod+1 workspace $ws1
bindsym $mod+2 workspace $ws2
bindsym $mod+3 workspace $ws3
bindsym $mod+4 workspace $ws4

# Move focused container to workspace
bindsym $mod+Shift+1 move container to workspace $ws1
bindsym $mod+Shift+2 move container to workspace $ws2
bindsym $mod+Shift+3 move container to workspace $ws3
bindsym $mod+Shift+4 move container to workspace $ws4

# Reload the configuration file
bindsym $mod+Shift+c reload

# Restart i3 inplace
bindsym $mod+Shift+r restart

# Exit i3
bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'Exit i3?' -B 'Yes' 'i3-msg exit'"

# Resize window
mode "resize" {
    bindsym j resize shrink width 10 px or 10 ppt
    bindsym k resize grow height 10 px or 10 ppt
    bindsym l resize shrink height 10 px or 10 ppt
    bindsym semicolon resize grow width 10 px or 10 ppt

    # Back to normal
    bindsym Return mode "default"
    bindsym Escape mode "default"
    bindsym $mod+r mode "default"
}

bindsym $mod+r mode "resize"

# Start i3bar with i3status
bar {
    status_command i3status
    position top
    colors {
        background #2E3440
        statusline #D8DEE9
        separator  #4C566A

        # class            border  backgr. text
        focused_workspace  #88C0D0 #88C0D0 #2E3440
        active_workspace   #4C566A #4C566A #D8DEE9
        inactive_workspace #3B4252 #3B4252 #D8DEE9
        urgent_workspace   #BF616A #BF616A #D8DEE9
    }
}

# Window colors
# class                 border  backgr. text    indicator child_border
client.focused          #88C0D0 #88C0D0 #2E3440 #88C0D0   #88C0D0
client.focused_inactive #4C566A #4C566A #D8DEE9 #4C566A   #4C566A
client.unfocused        #3B4252 #3B4252 #D8DEE9 #3B4252   #3B4252
client.urgent           #BF616A #BF616A #D8DEE9 #BF616A   #BF616A

# Gaps
gaps inner 10
gaps outer 5

# Disable window titlebars
for_window [class="^.*"] border pixel 2

# Autostart applications
exec --no-startup-id /opt/windsurf/bin/windsurf
EOF

# Add i3status config
COPY <<EOF ${HOME}/.config/i3status/config
# i3status configuration file
general {
    colors = true
    interval = 5
    color_good = "#A3BE8C"
    color_degraded = "#EBCB8B"
    color_bad = "#BF616A"
}

order += "cpu_usage"
order += "memory"
order += "disk /"
order += "ethernet _first_"
order += "tztime local"

cpu_usage {
    format = " CPU: %usage "
}

memory {
    format = " RAM: %used/%total "
    threshold_degraded = "1G"
    threshold_critical = "200M"
}

disk "/" {
    format = " Disk: %avail "
}

ethernet _first_ {
    format_up = " IP: %ip "
    format_down = " No network "
}

tztime local {
    format = " %Y-%m-%d %H:%M:%S "
}
EOF

# Configure X11
COPY <<EOF /etc/X11/xorg.conf
Section "ServerLayout"
    Identifier     "Layout0"
    Screen      0  "Screen0"
    InputDevice    "Mouse0" "CorePointer"
    InputDevice    "Keyboard0" "CoreKeyboard"
EndSection

Section "InputDevice"
    Identifier  "Keyboard0"
    Driver      "kbd"
EndSection

Section "InputDevice"
    Identifier  "Mouse0"
    Driver      "mouse"
    Option      "Protocol" "auto"
    Option      "Device" "/dev/input/mice"
    Option      "ZAxisMapping" "4 5 6 7"
EndSection

Section "Monitor"
    Identifier  "Monitor0"
    VendorName  "Unknown"
    ModelName   "Unknown"
    HorizSync   30.0 - 85.0
    VertRefresh 48.0 - 85.0
    Option      "DPMS"
EndSection

Section "Device"
    Identifier  "Card0"
    Driver      "dummy"
    VideoRam    256000
EndSection

Section "Screen"
    Identifier "Screen0"
    Device     "Card0"
    Monitor    "Monitor0"
    DefaultDepth     24
    SubSection "Display"
        Depth     24
        Modes     "1920x1080"
    EndSubSection
EndSection
EOF

# Extract Windsurf desktop file and icon
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    dpkg-dev \
    && apt-get download windsurf \
    && dpkg-deb -x windsurf_*_amd64.deb /tmp/windsurf-extracted \
    && cp /tmp/windsurf-extracted/usr/share/applications/windsurf.desktop /usr/share/applications/ \
    && cp /tmp/windsurf-extracted/usr/share/pixmaps/windsurf.png /usr/share/pixmaps/ \
    && rm -rf /tmp/windsurf-extracted windsurf_*_amd64.deb \
    && apt-get remove -y dpkg-dev \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Configure entrypoint
COPY <<EOF /usr/local/bin/entrypoint.sh
#!/bin/bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Logging functions
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] \$*" >&2
}

error() {
    log "ERROR: \$*"
    exit 1
}

# Default configuration
: "\${VNC_RESOLUTION:=1920x1080}"
: "\${VNC_PORT:=6901}"
: "\${DISPLAY:=:1}"

# Generate random VNC password
if ! VNC_PASSWORD=\$(head -c 12 /dev/urandom | base64); then
    error "Failed to generate VNC password"
fi

# Configure VNC
mkdir -p "\$HOME/.vnc"
echo "\$VNC_PASSWORD" | vncpasswd -f > "\$HOME/.vnc/passwd"
chmod 600 "\$HOME/.vnc/passwd"

# Create supervisor config
cat > /etc/supervisor/conf.d/windsurf.conf << 'EOSUPERVISOR'
[supervisord]
nodaemon=true
user=root
logfile=/var/log/supervisor/supervisord.log
pidfile=/var/run/supervisord.pid
childlogdir=/var/log/supervisor

[program:kasmvnc]
command=/usr/local/bin/kasmvnc --listen %(ENV_VNC_PORT)s --cert /etc/ssl/certs/ssl-cert-snakeoil.pem --key /etc/ssl/private/ssl-cert-snakeoil.key
user=windsurf
environment=HOME="/home/windsurf",USER="windsurf",DISPLAY="%(ENV_DISPLAY)s",VNC_RESOLUTION="%(ENV_VNC_RESOLUTION)s"
autorestart=true
priority=1
stdout_logfile=/var/log/supervisor/kasmvnc.log
stderr_logfile=/var/log/supervisor/kasmvnc.err
startretries=3
startsecs=5
stopwaitsecs=10

[program:i3]
command=/usr/bin/i3
user=windsurf
environment=HOME="/home/windsurf",USER="windsurf",DISPLAY="%(ENV_DISPLAY)s"
autorestart=true
priority=2
stdout_logfile=/var/log/supervisor/i3.log
stderr_logfile=/var/log/supervisor/i3.err
startretries=3
startsecs=5
stopwaitsecs=10

[program:windsurf]
command=/opt/windsurf/bin/windsurf
user=windsurf
environment=HOME="/home/windsurf",USER="windsurf",DISPLAY="%(ENV_DISPLAY)s"
autorestart=true
priority=3
stdout_logfile=/var/log/supervisor/windsurf.log
stderr_logfile=/var/log/supervisor/windsurf.err
startretries=3
startsecs=5
stopwaitsecs=10

[program:profile-sync]
command=/usr/local/bin/profile_sync.sh watch
user=windsurf
environment=HOME="/home/windsurf",USER="windsurf"
autorestart=true
priority=4
stdout_logfile=/var/log/supervisor/profile-sync.log
stderr_logfile=/var/log/supervisor/profile-sync.err
startretries=3
startsecs=5
stopwaitsecs=10
EOSUPERVISOR

# Initialize profile sync
/usr/local/bin/profile_sync.sh init

# Start pulseaudio for audio support
pulseaudio --start

# Wait for X server
log "Waiting for X server..."
timeout 30 bash -c 'until xdpyinfo -display "\$DISPLAY" >/dev/null 2>&1; do sleep 0.5; done' || error "X server failed to start"

# Configure display resolution
log "Configuring display resolution to \$VNC_RESOLUTION..."
if ! xrandr --output "\$(xrandr | grep -w connected | cut -d' ' -f1)" --mode "\$VNC_RESOLUTION"; then
    log "Warning: Failed to set resolution \$VNC_RESOLUTION, falling back to auto-configuration"
fi

# Start supervisord
log "Starting supervisord..."
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
EOF

RUN chmod +x /usr/local/bin/entrypoint.sh

# Install Windsurf
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    curl -fsSL "https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/windsurf.gpg" | \
        gpg --dearmor -o /usr/share/keyrings/windsurf-stable-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/windsurf-stable-archive-keyring.gpg arch=amd64] https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/apt stable main" | \
        tee /etc/apt/sources.list.d/windsurf.list > /dev/null && \
    apt-get update && \
    apt-get install -y windsurf && \
    rm -rf /var/lib/apt/lists/*

# Set up scripts and permissions
RUN mkdir -p /app && \
    chown -R windsurf:windsurf "${HOME}" "${STARTUPDIR}" /app

# Expose ports
EXPOSE ${VNC_PORT}

# Set working directory
WORKDIR ${HOME}

# Switch to non-root user
USER windsurf

# Use entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["--wait"]

# Create Windsurf config directory and add onboarding config
RUN mkdir -p "${HOME}/.config/windsurf"

COPY <<EOF ${HOME}/.config/windsurf/onboarding.json
{
  "items": [
    { "actionType": "ONBOARDING_ACTION_TYPE_AUTOCOMPLETE", "completed": true },
    { "actionType": "ONBOARDING_ACTION_TYPE_COMMAND", "completed": true },
    { "actionType": "ONBOARDING_ACTION_TYPE_CHAT", "completed": true }
  ]
}
EOF

# Create onboarding lock file
RUN touch "${HOME}/.config/windsurf/onboarding.json.lock" && \
    chown windsurf:windsurf "${HOME}/.config/windsurf/onboarding.json.lock"
