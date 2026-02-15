# Quick Reference

Fast lookup for common commands and configurations.

## Directory Structure

```
home_media/
 ent/ # Main media server stack (10 services)
 docker-compose.yml
 appdata/ # Config storage for all services
 dockhand/ # Docker UI (optional, standalone)
 tails/ # Utility services (optional)
 appdata/
 termix/ # Web terminal (optional, standalone)
 .env # Your secrets (NEVER commit!)
 .env.example # Template (safe to commit)
 .gitignore # Prevent secret commits
 README.md # Overview
 SETUP.md # Detailed setup guide (770+ lines)
 .github/
 DEPLOYMENT.md # GitHub deployment instructions
```

## Essential Files

| File | Purpose | Commit to Git? |
|------|---------|---|
| `ent/docker-compose.yml` | Main stack definition | Yes |
| `.env` | Your secrets (auth keys, IPs) | No (in .gitignore) |
| `.env.example` | Template for users | Yes |
| `.gitignore` | Prevent secret commits | Yes |
| `README.md` | Overview | Yes |
| `SETUP.md` | Setup guide | Yes |
| `.github/DEPLOYMENT.md` | GitHub deployment | Yes |

## Starting the Stack

```bash
cd ent/
docker-compose up -d
```

## Viewing Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f radarr

# Last 50 lines of specific service
docker-compose logs --tail=50 sonarr
```

## Stopping Services

```bash
# Stop all (containers persist)
docker-compose stop

# Stop specific service
docker-compose stop radarr

# Full teardown (containers removed, volumes kept)
docker-compose down

# Full teardown INCLUDING volumes (caution!)
docker-compose down -v
```

## Service Access

### Local Access (Same Network)
- Radarr: `http://localhost:7878`
- Sonarr: `http://localhost:8989`
- Lidarr: `http://localhost:8686`
- Jellyfin: `http://localhost:8096`
- Prowlarr: `http://localhost:9696`
- qBittorrent: `http://localhost:8080`
- Bazarr: `http://localhost:6767`
- Termix: `http://localhost:8081`
- Dockhand: `http://localhost:3000`

### Remote Access (via Tailscale)
Replace `YOUR_HOSTNAME` with your Tailscale hostname (e.g., `my-server.tail12345.ts.net`):
- Radarr: `https://radarr.YOUR_HOSTNAME`
- Sonarr: `https://sonarr.YOUR_HOSTNAME`
- etc.

## Configuration

### Get API Keys

```bash
# Radarr
curl -X GET "http://localhost:7878/api/v3/system/status" \
 -H "X-Api-Key: YOUR_API_KEY"

# Sonarr
curl -X GET "http://localhost:8989/api/v3/system/status" \
 -H "X-Api-Key: YOUR_API_KEY"

# Lidarr
curl -X GET "http://localhost:8686/api/v1/system/status" \
 -H "X-Api-Key: YOUR_API_KEY"
```

### Set Radarr Movie Folder

Via API:
```bash
curl -X POST "http://localhost:7878/api/v3/rootfolder" \
 -H "Content-Type: application/json" \
 -H "X-Api-Key: YOUR_API_KEY" \
 -d '{"path": "/data/media/movies"}'
```

### Prowlarr → Radarr Integration

1. In Prowlarr: Settings > Apps > Add Radarr
2. Name: `Radarr`
3. Host: `radarr`
4. Port: `7878`
5. API Key: (from Radarr > Settings > General)
6. Base URL: `/radarr`

Repeat for Sonarr (`sonarr`) and Lidarr (`lidarr`)

## Maintenance Commands

### Update Services

```bash
# Pull latest images
docker-compose pull

# Restart all services with new images
docker-compose up -d

# Verify all started
docker-compose ps
```

### Backup Configuration

```bash
# Backup all settings (includes secrets - store securely!)
tar -czf backup_$(date +%Y%m%d_%H%M%S).tar.gz \
 ent/appdata \
 .env

# Backup only application data (no secrets)
tar -czf backup_$(date +%Y%m%d_%H%M%S).tar.gz \
 ent/appdata
```

### Clean Up Docker

```bash
# Remove stopped containers
docker container prune

# Remove unused images
docker image prune

# Remove unused volumes
docker volume prune

# Full cleanup
docker system prune -a
```

## Permissions

### Fix Permission Issues

```bash
# Fix appdata ownership
sudo chown -R 1000:1000 ent/appdata
chmod -R 775 ent/appdata

# Fix media directory ownership
sudo chown -R 1000:1000 /data
chmod -R 755 /data
```

### Find Your PUID/PGID

```bash
id
# Output: uid=1000(user) gid=1000(group) groups=1000(group)
# PUID=1000, PGID=1000
```

## Environment Variables

Key variables in `.env`:

```bash
# System
PUID=1000
PGID=1000
TZ=America/Toronto

# Tailscale
TSDPROXY_AUTHKEY=tskey-auth-XXXXX
TSDPROXY_HOSTNAME=100.0.0.5

# Ports (optional, if not using Tailscale)
QBITTORRENT_WEBUI_PORT=8080
JELLYFIN_PORT=8096
```

## Volume Paths

Services mount these paths:

| Service | Inside Container | Host Path |
|---------|------------------|-----------|
| Radarr | `/data/media` | `/data/media` |
| Sonarr | `/data/media` | `/data/media` |
| Lidarr | `/data/media` | `/data/media` |
| qBittorrent | `/data/torrents` | `/data/torrents` |
| Jellyfin | `/data/media` | `/data/media` (read-only) |
| All *arr | `/config` | `./appdata/{service}` |

## Troubleshooting

### Check Service Health

```bash
# All services
docker-compose ps

# Specific service with detailed info
docker inspect {container_name}

# Service logs
docker logs {container_name}
```

### Test Service Connectivity

```bash
# Inside a container, ping another
docker-compose exec radarr ping sonarr

# Check if port is open
docker-compose exec radarr nc -zv qbittorrent 8080
```

### Restart Services

```bash
# Restart one
docker-compose restart radarr

# Restart all
docker-compose restart

# Recreate (harder reset)
docker-compose up -d
```

## Security Checklist

- [ ] `.env` contains your secrets (never commit)
- [ ] `.env` is in `.gitignore`
- [ ] Tailscale auth key is in `.env` only
- [ ] Default qBittorrent password changed
- [ ] Firewall blocks external access (only Tailscale)
- [ ] Backups are encrypted
- [ ] `.github/copilot-instructions.md` removed from public repo

## Getting Help

1. **Setup Issues**: See [SETUP.md](SETUP.md)
2. **Deployment**: See [.github/DEPLOYMENT.md](.github/DEPLOYMENT.md)
3. **Service Docs**:
 - Radarr: https://wiki.servarr.com/radarr
 - Sonarr: https://wiki.servarr.com/sonarr
 - Jellyfin: https://jellyfin.org/docs/
4. **Docker**: https://docs.docker.com/compose/

## File Locations

Key configuration files inside containers:

```
/config/ # Service configuration
 config.xml # Main config
 logs.db # Recent logs
 
/data/media/ # Organized media
 movies/ # Radarr manages
 tv/ # Sonarr manages
 music/ # Lidarr manages
 
/data/torrents/ # Download staging
 movies/ # qBittorrent category
 tv/
 music/
```

## Network

All services on dedicated network: `arr_network`

Service-to-service communication (internal):
- `radarr:7878`
- `sonarr:8989`
- `lidarr:8686`
- `qbittorrent:8080`
- `prowlarr:9696`

External access:
- Via Tailscale: `SERVICE_NAME.TAILSCALE_HOSTNAME`
- Local: `localhost:PORT`

---

**For detailed guides**: See [SETUP.md](SETUP.md)
**For deployment**: See [.github/DEPLOYMENT.md](.github/DEPLOYMENT.md)
