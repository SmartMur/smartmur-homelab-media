# Home Media Server - Setup Guide

Complete step-by-step setup and configuration guide for the Home Media Server stack.

## Prerequisites

- Docker Engine 20.10+ and Docker Compose 2.0+
- Linux system (Ubuntu 20.04+ recommended)
- Minimum 4GB RAM, 20GB storage (more depending on media collection)
- Tailscale account (free tier acceptable) for remote access
- Internet connection for initial setup

## Installation Steps

### Step 1: Clone Repository

```bash
git clone <your-repository-url> /home/lab/home_media
cd /home/lab/home_media
```

### Step 2: Create Environment Configuration

Copy the example environment file and fill in your values:

```bash
cp .env.example .env
nano .env
```

**Required values:**
- `TSDPROXY_AUTHKEY`: Get from https://login.tailscale.com/admin/settings/keys
- `TSDPROXY_HOSTNAME`: Your Tailscale server IP (or run `tailscale ip -4` on your server)
- `PUID`/`PGID`: Run `id` to get your user/group IDs
- `TZ`: Your timezone (see https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)

### Step 3: Prepare Data Directories

Create the expected directory structure (linked to your existing data):

```bash
# Create media organization directories
mkdir -p /data/media/{movies,tv,music}
mkdir -p /data/torrents/{movies,tv,music}

# Set appropriate permissions (adjust user:group to match your PUID:PGID)
sudo chown -R 1000:1000 /data
sudo chmod -R 755 /data
```

**Note**: If migrating from existing setup, symlink existing folders:
```bash
# Example: Link existing movie data
ln -s /path/to/existing/movies /data/media/movies

# Create empty folders for other types
mkdir -p /data/media/tv /data/media/music
```

### Step 4: Initialize Application Data Directories

```bash
cd ent/
mkdir -p appdata/{radarr,sonarr,lidarr,bazarr,prowlarr,qbittorrent,jellyfin,termix,dockhand}

# Set permissions so container user (UID 1000) can write
sudo chown -R 1000:1000 appdata/
chmod -R 775 appdata/
```

### Step 5: Start the Stack

```bash
# Start all services
docker-compose up -d

# Verify all services started
docker-compose ps
```

All services should show `Up` status. Check logs for any issues:

```bash
docker-compose logs -f  # All services
docker-compose logs -f radarr  # Specific service
```

### Step 6: Initialize Tailscale Access

If using TSDProxy for remote access (recommended):

```bash
# Check TSDProxy logs
docker-compose logs tsdproxy

# Verify Tailscale is connected
docker exec tsdproxy tailscale status
```

If you see authentication prompts, it means the auth key needs to be finalized:

```bash
# Check for auth URL in logs
docker-compose logs tsdproxy | grep auth

# Open the URL in a browser to approve the device
```

Once approved, your services will be accessible at:
- `radarr.YOUR_TAILSCALE_HOSTNAME`
- `sonarr.YOUR_TAILSCALE_HOSTNAME`
- etc.

## Service Configuration

Each service stores configuration in `./appdata/{service}/config.xml`. After initial startup, configure each:

### Radarr (Movies)

1. Access at `http://localhost:7878` (or via Tailscale)
2. **Settings > Media Management**:
   - **Movie Folder**: `/data/media/movies`
   - **Naming**:
     - Standard: `{Movie Title} ({Release Year})/{Movie Title} ({Release Year}) - {Quality Full}`
   - **Root Folders**: Add `/data/media`
3. **Settings > Download Clients**:
   - Add qBittorrent client
   - Host: `qbittorrent`
   - Port: `8080`
4. **Settings > Indexers**:
   - Leave empty or add via Prowlarr integration

### Sonarr (TV Shows)

1. Access at `http://localhost:8989` (or via Tailscale)
2. **Settings > Media Management**:
   - **TV Folder**: `/data/media/tv`
   - **Naming**:
     - Series: `{Series Title}`
     - Season: `Season {season:00}`
     - Episode: `{Series Title} - {season:00}e{episode:00} - {Episode Title} {Quality Full}`
   - **Root Folders**: Add `/data/media`
3. **Settings > Download Clients**: Add qBittorrent
4. **Settings > Indexers**: Connect to Prowlarr

### Lidarr (Music)

1. Access at `http://localhost:8686` (or via Tailscale)
2. **Settings > Media Management**:
   - **Music Folder**: `/data/media/music`
   - **Naming**:
     - Artist: `{Artist Name}`
     - Album: `{Album Title} ({Release Year})`
     - Track: `{track:00} - {Track Title}`
   - **Root Folders**: Add `/data/media`
3. **Settings > Download Clients**: Add qBittorrent
4. **Settings > Metadata Provider**: Configure preferred sources

### Prowlarr (Indexer Manager)

1. Access at `http://localhost:9696` (or via Tailscale)
2. **Settings > Apps**:
   - Add Radarr, Sonarr, Lidarr instances
   - Get API keys from each service (Settings > General)
3. **Indexers**: Add your preferred torrent/usenet indexers

### Bazarr (Subtitles)

1. Access at `http://localhost:6767` (or via Tailscale)
2. **Settings > Sonarr** / **Settings > Radarr**:
   - Enable integration
   - Add API keys from respective services
3. **Settings > Languages**: Select subtitle languages to download

### qBittorrent (Downloads)

1. Access at `http://localhost:8080` (or via Tailscale)
2. Default credentials: `admin` / `adminadmin`
   - **Highly recommend** changing password immediately
3. **Options > Downloads**:
   - Default Save Path: `/data/torrents/`
   - Keep torrents: Enable (for seeding)
4. Create download categories:
   - `movies` → `/data/torrents/movies`
   - `tv` → `/data/torrents/tv`
   - `music` → `/data/torrents/music`

### Jellyfin (Media Server)

1. Access at `http://localhost:8096` (or via Tailscale)
2. **Libraries** → Add Library:
   - Movie Library: `/data/media/movies`
   - TV Library: `/data/media/tv`
   - Music Library: `/data/media/music`
3. **Dashboard** → Plugins: Install preferred plugins
4. **Playback**: Configure subtitle, audio codec preferences

### Termix (Web Terminal)

1. Access at `http://localhost:8081` (or via Tailscale)
2. First access generates JWT token and password - save these
3. Use for system administration via browser

### Dockhand (Docker UI)

1. Access at `http://localhost:3000` (or via Tailscale)
2. Database auto-initialized in `./appdata/dockhand/`
3. Monitor and manage all Docker containers

## Media Organization Standard (Trash Guides)

The stack uses **Trash Guides** format for consistent organization:

### Movies
```
/data/media/movies/
├── Inception (2010)/
│   ├── Inception (2010) - 1080p.mkv
│   └── Inception (2010) - 1080p.srt
├── The Dark Knight (2008)/
└── Interstellar (2014)/
```

**Radarr Naming**:
```
{Movie Title} ({Release Year})/{Movie Title} ({Release Year}) - {Quality Full}
```

### TV Shows
```
/data/media/tv/
├── Breaking Bad/
│   ├── Season 01/
│   │   ├── Breaking Bad - 01e01 - Pilot [1080p].mkv
│   │   ├── Breaking Bad - 01e02 - Cat's in the Bag [1080p].mkv
│   │   └── ...
│   └── Season 02/
└── Better Call Saul/
```

**Sonarr Naming**:
```
{Series Title}/Season {season:00}/{Series Title} - {season:00}e{episode:00} - {Episode Title} {Quality Full}
```

### Music
```
/data/media/music/
├── Taylor Swift/
│   └── Midnights (2022)/
│       ├── 01 - Midnight.flac
│       ├── 02 - Karma.flac
│       └── ...
├── The Beatles/
│   ├── Abbey Road (1969)/
│   └── The White Album (1968)/
└── Dua Lipa/
```

**Lidarr Naming**:
```
{Artist Name}/{Album Title} ({Release Year})/{track:00} - {Track Title}
```

## Operations & Maintenance

### Viewing Logs

```bash
# All services
docker-compose logs -f

# Specific service (follow in real-time)
docker-compose logs -f radarr

# Last 50 lines
docker-compose logs --tail=50 sonarr

# Specific time range
docker-compose logs --since 2024-01-15 --until 2024-01-16 lidarr
```

### Updating Services

```bash
# Pull latest images
docker-compose pull

# Restart with new images
docker-compose up -d

# Verify all services healthy
docker-compose ps
```

### Backup & Restore

#### Backing Up Application Configuration

```bash
# Backup all application data
tar -czf home_media_backup_$(date +%Y%m%d_%H%M%S).tar.gz \
  ent/appdata/ \
  .env

# Store securely (never commit .env!)
```

#### Restoring from Backup

```bash
# Extract backup
tar -xzf home_media_backup_YYYYMMDD_HHMMSS.tar.gz

# Restart stack
docker-compose down
docker-compose up -d

# Services should retain all settings
```

### Cleaning Up

```bash
# Stop stack without removing volumes
docker-compose stop

# Restart later
docker-compose start

# Full cleanup (removes containers, keeps volumes)
docker-compose down

# Full cleanup INCLUDING volumes (caution!)
docker-compose down -v
```

## Troubleshooting

### Service Won't Start

1. Check logs:
   ```bash
   docker-compose logs {service-name}
   ```

2. Common issues:
   - **Port already in use**: Change ports in `.env`
   - **Permission denied**: Run `sudo chown -R 1000:1000 appdata/`
   - **Disk space**: Check with `df -h /data`

### Downloads Not Working

1. Verify qBittorrent is accessible
2. Ensure download categories exist in qBittorrent
3. Check Radarr/Sonarr can connect to qBittorrent:
   - Settings > Download Clients > Test Connection
4. Verify `/data/torrents` has write permissions:
   ```bash
   touch /data/torrents/test.txt
   rm /data/torrents/test.txt
   ```

### Jellyfin Not Showing Media

1. Verify library paths point to correct directories
2. Check permissions: `ls -la /data/media/movies`
3. Force library scan: Jellyfin Dashboard > Scan All Libraries
4. Check Jellyfin logs for encoding errors

### TSDProxy Not Accessible

1. Verify Tailscale is installed on host
2. Check TSDProxy container logs:
   ```bash
   docker-compose logs tsdproxy
   ```
3. Verify auth key is valid (check Tailscale admin console)
4. Ensure Docker socket is mounted: `docker-compose ps tsdproxy`

### API Connection Issues

1. Get API keys:
   - Radarr: Settings > General > API Key
   - Sonarr: Settings > General > API Key
   - Lidarr: Settings > General > API Key

2. Test connection:
   ```bash
   curl -X GET "http://localhost:7878/api/v3/system/status?apikey=YOUR_KEY"
   ```

3. For Prowlarr integration, ensure correct hostname:
   - Use container name, not `localhost`: `http://radarr:7878`

## Advanced Configuration

### Custom Networking

To add additional services or integrate with other stacks:

1. Edit `docker-compose.yml`
2. Add new service with labels:
   ```yaml
   new-service:
     image: your-image
     networks:
       - default
     labels:
       tsdproxy.enable: "true"
       tsdproxy.name: "your-service-name"
   ```

3. Access at `your-service-name.YOUR_TAILSCALE_HOSTNAME`

### Volume Performance

For large media libraries, consider:

1. **Dedicated disk**: Mount `/data` to separate SSD/HDD
2. **Read-only mounts**: Jellyfin uses `:ro` tag (read-only)
3. **Docker volumes**: Named volumes (`tsdproxydata:`) persist outside containers

### Docker Cleanup

To save disk space and remove unused images/containers:

```bash
# Remove stopped containers
docker container prune

# Remove unused images
docker image prune

# Remove unused volumes
docker volume prune

# Full cleanup (all unused)
docker system prune -a
```

## Performance Tuning

### For Slow Machines

Reduce resource usage by:

1. Disabling TSDProxy if not using Tailscale
2. Limiting Jellyfin transcoding: Settings > Playback > Transcoding
3. Running media analysis during off-peak hours
4. Reducing Docker logging: Change `json-file` to `none` in compose

### For High-Load Scenarios

Optimize for many concurrent users/downloads:

1. Allocate more resources: `docker update --cpus 2 container_name`
2. Use dedicated hardware: Separate server for downloads
3. Enable qBittorrent rate limiting
4. Use Jellyfin direct streaming (avoid transcoding)

## Getting Help

1. Check service logs (see Operations section)
2. Verify all prerequisites are met
3. Test network connectivity: `docker-compose exec radarr ping sonarr`
4. Search GitHub issues in relevant projects:
   - Radarr: github.com/radarr/radarr
   - Sonarr: github.com/sonarr/sonarr
   - Jellyfin: github.com/jellyfin/jellyfin

---

For detailed service documentation:
- **Radarr**: https://wiki.servarr.com/en/radarr
- **Sonarr**: https://wiki.servarr.com/en/sonarr
- **Lidarr**: https://wiki.servarr.com/en/lidarr
- **Jellyfin**: https://jellyfin.org/docs/
- **qBittorrent**: https://www.qbittorrent.org/
- **Prowlarr**: https://wiki.servarr.com/en/prowlarr
- **Bazarr**: https://www.bazarr.media/
