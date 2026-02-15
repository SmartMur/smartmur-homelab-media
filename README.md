# Home Media Server

Complete Docker-based self-hosted media server stack with secure configuration management.

## Documentation

**Start here**: [INDEX.md](INDEX.md) - Complete guide to all documentation

Or jump to:
- **New to this?** → [DEPLOYMENT.md](DEPLOYMENT.md) (full system setup from scratch)
- **Already have Docker?** → [Quick Start](#quick-start) below
- **Need security setup?** → [SECURITY.md](SECURITY.md)
- **Need commands?** → [COMMANDS.md](COMMANDS.md)
- **Already running?** → Run `./health_check.sh`

## Stack Components

- **Radarr** - Movies management and automation
- **Sonarr** - TV shows management and automation 
- **Lidarr** - Music management and automation
- **Readarr** - Books/Ebooks management and automation
- **Prowlarr** - Centralized indexer manager
- **Bazarr** - Automatic subtitle downloading
- **qBittorrent** - Torrent client for downloads
- **Jellyfin** - Open-source media streaming server
- **Jellyseerr** - User request/discovery interface (integrates with Jellyfin, Radarr, Sonarr, Readarr)
- **Plex** - Premium media streaming server (requires subscription)
- **Termix** - Web-based terminal for remote access
- **Dockhand** - Docker management UI

See [SETUP.md](SETUP.md) for detailed configuration instructions.

**For production deployment**, see [DEPLOYMENT.md](DEPLOYMENT.md) for complete system setup including Docker installation, UFW firewall, Tailscale configuration, health checks, and monitoring.

## Quick Start

1. Clone this repository
2. Copy `.env.example` to `.env` and fill in your values:
 ```bash
 cp .env.example .env
 ```
3. Ensure your data directories exist:
 ```bash
 mkdir -p /data/media/{movies,tv,music}
 mkdir -p /data/torrents/{movies,tv,music}
 ```
4. Start the stack:
 ```bash
 cd ent/
 docker-compose up -d
 ```

## Directory Structure

```
home_media/
 ent/ # Main media server stack
 docker-compose.yml # Main compose definition
 appdata/ # Application config volumes
 radarr/
 sonarr/
 lidarr/
 bazarr/
 prowlarr/
 qbittorrent/
 jellyfin/
 termix/
 dockhand/
 dockhand/ # Standalone Docker UI (optional)
 tails/ # Utility services (optional)
 termix/ # Standalone terminal (optional)
 .env.example # Configuration template (public)
 .env # Your secrets (local only, .gitignore'd)
 .gitignore # Prevent accidental secret commits
 README.md # This file
 SETUP.md # Detailed setup guide
```

## External Data Structure

This stack expects the following structure in `/data`:

```
/data/
 media/ # Final organized media
 movies/ # Movies in format: Title (Year)/
 tv/ # TV shows in format: Series/Season NN/
 music/ # Music in format: Artist/Album (Year)/
 torrents/ # Download staging (organized by type)
 movies/
 tv/
 music/
 download/ # (optional) Raw download directory
```

## Security Notes

### Access Control (Tailscale-Only)
- **No ports exposed to internet** - All services accessed via Tailscale VPN
- TSDProxy provides automatic reverse proxy with Tailscale authentication
- Internal network isolation prevents unauthorized access

### Authentication Status
- **Secured**: Jellyfin (user accounts), Plex (Plex account), Radarr/Sonarr/Lidarr/Readarr (API keys)
- **Manual Setup Required**: qBittorrent (change default credentials immediately)
- **Recommend Password**: Prowlarr, Bazarr (no built-in auth, add via Settings)
- **No Auth Available**: Termix, Dockhand (rely on Tailscale network access only)

### Best Practices
1. **Secrets Management**: All sensitive values (.env) excluded from git via .gitignore
2. **Tailscale Mandatory**: Deploy only within Tailscale network - no port forwarding
3. **First Run Setup**: 
 - Change qBittorrent admin password immediately
 - Create Jellyfin user account on first access
 - Link Plex account or use claim token
 - Disable Termix/Dockhand if not actively used
4. **Network Security**: Services isolated on internal Docker network, no direct internet exposure

## Services Quick Links (via Tailscale)

After setup and TSDProxy initialization:

- Radarr: `https://radarr.YOUR_TAILSCALE_IP`
- Sonarr: `https://sonarr.YOUR_TAILSCALE_IP`
- Lidarr: `https://lidarr.YOUR_TAILSCALE_IP`
- Readarr: `https://readarr.YOUR_TAILSCALE_IP`
- Jellyfin: `https://jellyfin.YOUR_TAILSCALE_IP`
- Jellyseerr: `https://jellyseerr.YOUR_TAILSCALE_IP` (requests interface)
- Plex: `https://plex.YOUR_TAILSCALE_IP`
- Prowlarr: `https://prowlarr.YOUR_TAILSCALE_IP`
- qBittorrent: `https://qbittorrent.YOUR_TAILSCALE_IP`
- Bazarr: `https://bazarr.YOUR_TAILSCALE_IP`
- Termix: `https://termix.YOUR_TAILSCALE_IP` (no password - Tailscale access only)
- Dockhand: `https://dockhand.YOUR_TAILSCALE_IP` (no password - Tailscale access only)

(Actual domain depends on your Tailscale hostname)

## For More Information

See **[SETUP.md](SETUP.md)** for:
- Prerequisites and system requirements
- Detailed configuration steps for each service
- Trash Guides media organization standard
- Operations and troubleshooting
- Advanced configuration options

## License

[Your License Here]
