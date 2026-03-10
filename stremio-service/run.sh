#!/usr/bin/with-contenv bashio

# ==============================================================================
# Stremio Streaming Service - Home Assistant Add-on
# Runs the Stremio server.js with Node.js
# ==============================================================================

declare server_url

# Read configuration
server_url=$(bashio::config 'server_url')

# Set up data directory for persistent storage
export STREMIO_DATA="/data/stremio-server"
mkdir -p "${STREMIO_DATA}"

# Point ffmpeg/ffprobe to the system-installed binaries
export FFMPEG_BIN="$(which ffmpeg)"
export FFPROBE_BIN="$(which ffprobe)"

# Set HOME and APP_PATH so server.js stores its config/cache in persistent storage
export HOME="${STREMIO_DATA}"
export APP_PATH="${STREMIO_DATA}"

# Advertise the host's IP address to Stremio clients for direct stream connections
export IPADDRESS="$(bashio::network.ipv4_address)"

# Allow connections from all interfaces (not just localhost)
export NO_CORS=1

# Disable casting/network device discovery (not needed in Docker/addon context)
export CASTING_DISABLED=1

# Download server.js if a custom URL is configured and differs from the built-in one
SERVER_JS="/opt/stremio/server.js"

if bashio::config.has_value 'server_url'; then
    BUILT_IN_URL="https://dl.strem.io/server/v4.20.16/desktop/server.js"
    if [ "${server_url}" != "${BUILT_IN_URL}" ]; then
        bashio::log.info "Downloading server.js from ${server_url}..."
        if curl -fSL "${server_url}" -o /opt/stremio/server.js.tmp; then
            mv /opt/stremio/server.js.tmp /opt/stremio/server.js
            bashio::log.info "Server.js updated."
        else
            bashio::log.warning "Failed to download custom server.js, using built-in version."
        fi
    fi
fi

if [ ! -f "${SERVER_JS}" ]; then
    bashio::log.error "server.js not found at ${SERVER_JS}!"
    exit 1
fi

ulimit -n 65536

bashio::log.info "Starting Stremio streaming server..."

# Run the Stremio streaming server in the data directory
cd "${STREMIO_DATA}"

# Start server.js in the background so we can health-check it
node --max-old-space-size=1024 "${SERVER_JS}" &
SERVER_PID=$!

# Give the server a moment to start
sleep 5

# Health check: verify the server is responding
RETRIES=0
MAX_RETRIES=6
while [ ${RETRIES} -lt ${MAX_RETRIES} ]; do
    if curl -sf "http://127.0.0.1:11470" > /dev/null 2>&1; then
        bashio::log.info "Stremio server is running on port 11470 (HTTP) and 12470 (HTTPS)"
        break
    fi
    RETRIES=$((RETRIES + 1))
    if [ ${RETRIES} -lt ${MAX_RETRIES} ]; then
        bashio::log.info "Waiting for server... (${RETRIES}/${MAX_RETRIES})"
        sleep 5
    else
        bashio::log.warning "Server health check failed after ${MAX_RETRIES} attempts."
    fi
done

# Wait for the server process — if it exits, the add-on stops
wait "${SERVER_PID}"
EXIT_CODE=$?

if [ ${EXIT_CODE} -ne 0 ]; then
    bashio::log.error "Stremio server exited with code ${EXIT_CODE}"
fi

exit "${EXIT_CODE}"
