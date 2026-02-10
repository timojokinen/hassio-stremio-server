# Stremio Streaming Service - Home Assistant Add-on

[![Add repository](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Ftimojokinen%2Fhassio-stremio-server)

Run Stremio's streaming server (`server.js`) on your Home Assistant machine. Offload torrent handling and transcoding from low-powered TVs to your always-on HA box.

## How It Works

This add-on runs the headless [stremio-service](https://github.com/Stremio/stremio-service) streaming server — the same `server.js` that powers the desktop app, minus the GUI. Your TV runs the lightweight Stremio UI and connects to this server for the heavy lifting.

Components:
- **Node.js** running `server.js` (from Stremio's CDN)
- **ffmpeg/ffprobe** for transcoding
- Ports **11470** (HTTP) and **12470** (HTTPS)

## Installation

1. Click the badge above, or manually add this repository URL in **Settings → Add-ons → Add-on Store → ⋮ → Repositories**:
   ```
   https://github.com/timojokinen/hassio-stremio-server
   ```
2. Install **Stremio Streaming Service**
3. Start the add-on
4. Point your Stremio client to `http://<HA_IP>:11470`

## Client Setup

In your Stremio app (TV, web, or desktop), go to **Settings** and set the **Streaming Server URL** to:

```
http://<YOUR_HA_IP>:11470
```

For Stremio Web, visit [web.stremio.com](https://web.stremio.com) and configure the server URL in Settings.

## Configuration

| Option       | Default                                                  | Description                              |
| ------------ | -------------------------------------------------------- | ---------------------------------------- |
| `server_url` | `https://dl.strem.io/server/v4.20.16/desktop/server.js`  | Server.js download URL (change to upgrade) |

To update server.js, change `server_url` to a new version URL and restart:
```
https://dl.strem.io/server/{VERSION}/desktop/server.js
```

## Network

| Port    | Description        |
| ------- | ------------------ |
| `11470` | HTTP streaming     |
| `12470` | HTTPS streaming    |

## Architecture

| Arch    | Supported |
| ------- | --------- |
| amd64   | ✅        |
| aarch64 | ✅        |

## Data

Server data is persisted in `/data/stremio-server` and survives restarts/updates.

## Troubleshooting

- **Port conflict**: Ensure nothing else is using 11470/12470
- **Can't connect**: Verify HA and client are on the same network; test with `curl http://<HA_IP>:11470`
- **Use HTTP**: Stremio clients expect `http://`, not `https://`, on port 11470

## Development

Quit any local Stremio app before testing (port 11470 conflict). Access at `http://localhost:11470`.

## License

GPL-2.0 — [stremio-service](https://github.com/Stremio/stremio-service/blob/master/LICENSE.md)
