ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.20
FROM ${BUILD_FROM}

# Install Node.js, ffmpeg, and runtime dependencies
RUN apk add --no-cache \
    nodejs \
    ffmpeg \
    curl \
    ca-certificates

# Create working directories
RUN mkdir -p /opt/stremio /data/stremio-server

# Download server.js at build time (default version, can be overridden at runtime)
ARG SERVER_VERSION=v4.20.16
RUN curl -fSL "https://dl.strem.io/server/${SERVER_VERSION}/desktop/server.js" \
    -o /opt/stremio/server.js

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

# Stremio server ports: 11470 (HTTP), 12470 (HTTPS)
EXPOSE 11470 12470

# Labels
LABEL \
    io.hass.name="Stremio Streaming Service" \
    io.hass.description="Stremio streaming server for local network streaming" \
    io.hass.arch="amd64|aarch64" \
    io.hass.type="addon" \
    io.hass.version="${BUILD_VERSION}"

CMD [ "/run.sh" ]
