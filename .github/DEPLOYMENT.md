# GitHub Deployment Instructions

Complete guide to deploying the Home Media Server stack from this repository.

## Pre-Deployment Checklist

- [ ] Docker Engine 20.10+ and Docker Compose 2.0+ installed
- [ ] Linux system (Ubuntu 20.04+ recommended)
- [ ] Tailscale account created (free at https://tailscale.com)
- [ ] Tailscale auth key generated (https://login.tailscale.com/admin/settings/keys)
- [ ] At least 20GB free disk space
- [ ] Network connectivity for initial setup

## Step 1: Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/home-media-server.git
cd home-media-server
```

## Step 2: Create Your Environment File

The repository includes `.env.example` as a template. You **must** create an actual `.env` file:

```bash
cp .env.example .env
```

The `.env` file is **never committed to git** (see `.gitignore`) and contains your secrets.

## Step 3: Configure Your Secrets

Edit `.env` and fill in your actual values:

```bash
nano .env
```

### Required Environment Variables

**System Configuration**:
- `PUID=1000` - Your user ID (run `id` to check)
- `PGID=1000` - Your group ID
- `TZ=America/Toronto` - Your timezone

**Tailscale Configuration** (for remote access):
1. Get auth key: https://login.tailscale.com/admin/settings/keys
 - Click "Generate auth key..."
 - Copy the key and paste into `.env` as `TSDPROXY_AUTHKEY`

2. Get your server's Tailscale IP:
 ```bash
 # After Tailscale is running on your server:
 tailscale ip -4
 ```
 - Use this IP for `TSDPROXY_HOSTNAME`

**Example .env**:
```bash
PUID=1000
PGID=1000
TZ=America/Toronto
DNS_1=1.1.1.1
DNS_2=1.0.0.1

# Your Tailscale auth key
TSDPROXY_AUTHKEY=tskey-auth-XXXXXXXXXXXXXXXXXX
# Your server's Tailscale IP
TSDPROXY_HOSTNAME=100.0.0.5

# Optional: Port overrides
QBITTORRENT_WEBUI_PORT=8080
JELLYFIN_PORT=8096
```

## Step 4: Prepare Data Directories

The stack expects media organized in `/data`:

```bash
# Create base structure
mkdir -p /data/media/{movies,tv,music}
mkdir -p /data/torrents/{movies,tv,music}

# Set permissions (replace 1000:1000 with your PUID:PGID if different)
sudo chown -R 1000:1000 /data
sudo chmod -R 755 /data
```

### If Migrating Existing Media

Link your existing media to the new structure:

```bash
# Example: Link existing movie library
mv /path/to/movies /data/media/movies

# OR create symlink to existing location
ln -s /mnt/external/movies /data/media/movies

# Create empty folders for other types
mkdir -p /data/media/tv /data/media/music
mkdir -p /data/torrents/{movies,tv,music}
```

## Step 5: Start the Stack

All services are in the `ent/` directory:

```bash
cd ent/
docker-compose up -d
```

Verify services are running:

```bash
docker-compose ps
```

All services should show `Up` status. If any show `Exit`, check logs:

```bash
docker-compose logs {service-name}
```

## Step 6: Initialize Tailscale (First Time Only)

On your server, install and initialize Tailscale:

```bash
# Install Tailscale (Ubuntu/Debian)
curl -fsSL https://tailscale.com/install.sh | sh

# Initialize with auth key from .env
sudo tailscale up --authkey=tskey-auth-XXXXX
```

Then verify TSDProxy is connected:

```bash
docker-compose logs tsdproxy | grep -i success
```

If you see an approval URL, open it in a browser and approve the device.

## Step 7: Access Your Services

Once TSDProxy is initialized, services are accessible at:

| Service | URL | Local Port |
|---------|-----|-----------|
| Radarr | `radarr.YOUR_TAILSCALE_HOSTNAME` | localhost:7878 |
| Sonarr | `sonarr.YOUR_TAILSCALE_HOSTNAME` | localhost:8989 |
| Lidarr | `lidarr.YOUR_TAILSCALE_HOSTNAME` | localhost:8686 |
| Jellyfin | `jellyfin.YOUR_TAILSCALE_HOSTNAME` | localhost:8096 |
| Prowlarr | `prowlarr.YOUR_TAILSCALE_HOSTNAME` | localhost:9696 |
| qBittorrent | `qbittorrent.YOUR_TAILSCALE_HOSTNAME` | localhost:8080 |
| Bazarr | `bazarr.YOUR_TAILSCALE_HOSTNAME` | localhost:6767 |
| Termix | `termix.YOUR_TAILSCALE_HOSTNAME` | localhost:8081 |
| Dockhand | `dockhand.YOUR_TAILSCALE_HOSTNAME` | localhost:3000 |

### Finding Your Tailscale Hostname

Check your Tailscale admin console: https://login.tailscale.com/admin/machines

Your server will appear with a hostname like `my-server.tail12345.ts.net`

**Important**: If Tailscale is not accessible from outside your network, add `--advertise-routes` during setup for full remote access (consult Tailscale docs).

## Step 8: Configure Each Service

See **[SETUP.md](../SETUP.md)** for detailed configuration of:
- Radarr (movies)
- Sonarr (TV shows)
- Lidarr (music)
- Prowlarr (indexer manager)
- Bazarr (subtitles)
- qBittorrent (downloads)
- Jellyfin (streaming)
- Termix (web terminal)
- Dockhand (Docker UI)

## Troubleshooting Deployment

### Services Won't Start

```bash
# Check Docker daemon
docker ps

# Check compose file syntax
docker-compose config

# View detailed logs
docker-compose logs -f
```

### Permission Issues

```bash
# Fix permissions on appdata
sudo chown -R 1000:1000 ent/appdata
chmod -R 775 ent/appdata

# Fix permissions on data
sudo chown -R 1000:1000 /data
chmod -R 755 /data
```

### Disk Space Issues

```bash
# Check available space
df -h /data

# Check Docker volumes
docker system df
```

### TSDProxy Not Connecting

1. Verify Tailscale is installed and running:
 ```bash
 tailscale status
 ```

2. Check auth key is valid:
 ```bash
 docker-compose logs tsdproxy | grep auth
 ```

3. Manually approve if needed (check TSDProxy logs for URL)

## Security Notes

**Critical**: The `.env` file contains sensitive secrets:
- Tailscale auth keys
- API credentials (will be stored here after setup)
- Server configuration

**Never**:
- Commit `.env` to git (it's in `.gitignore`)
- Share the contents of `.env`
- Push your modified docker-compose files with hardcoded secrets
- Store backups unencrypted

**Always**:
- Keep `.env` locally only
- Backup `.env` securely (encrypted drive)
- Regenerate Tailscale auth keys if compromised
- Use strong passwords for all services

## Backup & Recovery

### Backup Your Configuration

```bash
# Create backup of all settings
tar -czf home_media_backup_$(date +%Y%m%d).tar.gz \
 ent/appdata/ \
 .env

# Store securely (encrypted backup)
```

### Restore from Backup

```bash
# Extract backup
tar -xzf home_media_backup_YYYYMMDD.tar.gz

# Restart services
docker-compose down
docker-compose up -d
```

## Updating Services

```bash
cd ent/

# Pull latest container images
docker-compose pull

# Restart with new images
docker-compose up -d

# Verify all services started
docker-compose ps
```

## Optional: Other Stacks

The repository includes additional optional stacks:

### tails/ - Utility Services
Includes Stirling PDF, Audiobookshelf, and SearXNG (privacy search engine)

```bash
cd tails/
docker-compose up -d
```

### dockhand/ - Standalone Docker UI
If you want to run Dockhand separately from the main stack

```bash
cd dockhand/
docker-compose up -d
```

### termix/ - Standalone Web Terminal
If you want to run Termix separately

```bash
cd termix/
docker-compose up -d
```

## Getting Help

1. Check [SETUP.md](../SETUP.md) for detailed configuration
2. Review Docker logs: `docker-compose logs {service}`
3. Search GitHub issues: https://github.com/YOUR_USERNAME/home-media-server/issues
4. Consult service documentation:
 - **Radarr**: https://wiki.servarr.com/radarr
 - **Sonarr**: https://wiki.servarr.com/sonarr
 - **Jellyfin**: https://jellyfin.org/docs/
 - **Tailscale**: https://tailscale.com/kb/

## Next Steps

1. Deployed stack
2. Configured Tailscale access
3. → Configure each service (see SETUP.md)
4. → Add media to libraries
5. → Enjoy your media!

---

**Last Updated**: 2024
**Repository**: https://github.com/YOUR_USERNAME/home-media-server
