# Docker & System Commands Reference

Quick reference for common Docker, Linux, and troubleshooting commands.

## Essential Docker Commands

### View Status
```bash
# All containers
docker compose ps

# All containers with more detail
docker compose ps -a

# Get container IP
docker compose inspect radarr | grep "IPAddress"
```

### View Logs
```bash
# All services (live)
docker compose logs -f

# All services (last 50 lines)
docker compose logs --tail=50

# Specific service (live)
docker compose logs -f radarr

# Specific service (last 100 lines)
docker compose logs --tail=100 sonarr

# Follow specific service for 5 minutes
docker compose logs -f --tail=20 jellyfin | head -100

# Show errors only
docker compose logs | grep -i error

# From specific time
docker compose logs --since 10m  # Last 10 minutes
```

### Start/Stop Services
```bash
# Start all
docker compose up -d

# Start specific service
docker compose up -d radarr

# Stop all (containers kept)
docker compose stop

# Stop specific service
docker compose stop radarr

# Stop with grace period (30 sec to shutdown)
docker compose stop -t 30

# Full shutdown (containers removed, volumes kept)
docker compose down

# Full shutdown INCLUDING volumes (careful!)
docker compose down -v

# Restart all
docker compose restart

# Restart specific
docker compose restart qbittorrent
```

### Execute Commands in Container
```bash
# Open bash shell
docker compose exec radarr bash

# Run single command
docker compose exec radarr ls -la /config

# Run as specific user (root)
docker compose exec -u root radarr apt-get update

# Check file permissions
docker compose exec radarr ls -la /data/media

# Test network connection
docker compose exec radarr ping sonarr

# Check disk space
docker compose exec radarr df -h /data
```

### Debug Container Issues
```bash
# Full container info
docker compose inspect radarr

# Environment variables
docker compose exec radarr env | grep -i puid

# Process list
docker compose exec radarr ps aux

# Network config
docker compose exec radarr ip addr

# Check if port is open
docker compose exec radarr nc -zv localhost 8080
```

## System Commands

### Linux File Operations
```bash
# Check disk space
df -h /data

# Disk space by folder (sorted)
du -sh /data/* | sort -rh

# Find large files
find /data -size +5G -type f

# List files by size
ls -lahS /data/torrents/ | head -20

# Change permissions recursively
chmod -R 755 /data

# Change ownership
chown -R 1000:1000 /data

# Compress directory
tar -czf backup.tar.gz /data

# Extract archive
tar -xzf backup.tar.gz -C /
```

### Process & System Monitoring
```bash
# Real-time system stats
top

# Docker container stats
docker stats

# Memory usage
free -h

# CPU info
nproc

# Network connections
sudo netstat -tlnp | grep docker

# Or modern version
sudo ss -tlnp | grep docker
```

### Networking
```bash
# Check Tailscale status
tailscale status

# Get Tailscale IP
tailscale ip -4

# Check if service is responding
curl -I http://localhost:8080

# Test port connectivity
nc -zv radarr 7878

# DNS resolution
nslookup radarr

# Trace network route
tracert radarr
```

## Troubleshooting Scenarios

### Scenario 1: Container Won't Start
```bash
# View full error
docker compose logs radarr

# Restart with verbose output
docker compose up radarr

# Check if port already in use
sudo lsof -i :8080

# Inspect full config
docker compose config radarr
```

### Scenario 2: Services Can't Reach Each Other
```bash
# Test from one container to another
docker compose exec radarr ping sonarr
docker compose exec radarr ping qbittorrent:8080

# Check Docker network
docker network inspect arr_network

# Verify DNS works
docker compose exec radarr nslookup sonarr
```

### Scenario 3: Permission Denied Errors
```bash
# Check appdata permissions
ls -la ent/appdata/

# Fix permissions (for UID 1000)
sudo chown -R 1000:1000 ent/appdata/
sudo chmod -R 775 ent/appdata/

# Check /data permissions
ls -la /data

# Fix /data permissions
sudo chown -R 1000:1000 /data
sudo chmod -R 755 /data
```

### Scenario 4: Out of Disk Space
```bash
# Find what's consuming space
du -sh /data/* | sort -rh

# Find old torrent files
find /data/torrents -type f -mtime +30 -ls

# Remove old files (30+ days)
find /data/torrents -type f -mtime +30 -delete

# Clean Docker system
docker system prune -a --volumes

# Find and remove large files
find /data -size +10G -type f -exec ls -lh {} \;
```

### Scenario 5: Tailscale Not Connecting
```bash
# Check Tailscale daemon
sudo systemctl status tailscaled

# Restart Tailscale
sudo systemctl restart tailscaled

# Check if already authenticated
tailscale status

# Re-authenticate
sudo tailscale up

# Check TSDProxy logs
docker compose logs tsdproxy

# Verify auth key exists and is valid
grep TSDPROXY_AUTHKEY .env
```

### Scenario 6: Port Exposure (SECURITY CHECK)
```bash
# Should return EMPTY (no exposed ports!)
sudo netstat -tlnp | grep -E "(8080|8096|8989|7878|8686)"

# Or
sudo ss -tlnp | grep docker

# Verify only Tailscale access
sudo ufw status
```

## Container Cleanup Operations

### Remove Old/Stopped Containers
```bash
# List all containers (including stopped)
docker ps -a

# Remove specific stopped container
docker rm container_name

# Remove all stopped containers
docker container prune

# Force remove running container (emergency only!)
docker rm -f container_name
```

### Update/Rebuild Stack
```bash
# Pull latest images
docker compose pull

# Rebuild with latest images
docker compose up -d

# Force rebuild images
docker compose up -d --build

# Remove old images
docker image prune -a
```

## Health Check One-Liners

```bash
# Quick status check
docker compose ps && echo "---" && tailscale status | head -3

# All services responding?
for svc in radarr sonarr lidarr jellyfin; do
  docker compose exec $svc ping -c 1 qbittorrent && echo "$svc: OK" || echo "$svc: FAIL"
done

# Disk space warning
USAGE=$(df /data | awk 'NR==2 {print $5}' | sed 's/%//')
[ $USAGE -gt 80 ] && echo "DISK WARNING: ${USAGE}% used" || echo "Disk: OK (${USAGE}%)"

# Check for errors in past hour
docker compose logs --since 1h | grep -i error | wc -l | xargs echo "Errors in past hour:"

# Show last error
docker compose logs | grep -i error | tail -1
```

## System Setup Commands (From Scratch)

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up

# Setup UFW Firewall
sudo ufw allow 22
sudo ufw enable

# Clone repository
cd ~
wget https://github.com/YOUR_USER/home_media/archive/main.zip
unzip main.zip
cd home_media

# Setup env
cp .env.example .env
nano .env  # Edit with your values

# Start stack
cd ent
docker compose pull
docker compose up -d
```

## Backup Commands

```bash
# Backup appdata
tar -czf appdata_backup_$(date +%Y%m%d).tar.gz ent/appdata/

# Backup encrypted .env
gpg --symmetric --cipher-algo AES256 .env -o .env.gpg

# Restore appdata
tar -xzf appdata_backup_20260214.tar.gz -C ./

# Restore .env
gpg --decrypt .env.gpg > .env

# Backup entire stack (except media)
tar -czf home_media_backup.tar.gz \
  --exclude=ent/appdata/plex \
  --exclude=ent/appdata/jellyfin \
  ~/home_media/
```

## Performance Tuning

```bash
# Check Docker resource limits (should be none/unlimited)
docker stats --no-stream

# Check container memory usage
docker compose stats --no-stream

# Monitor real-time
watch docker stats

# Check CPU throttling
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Set resource limits (edit docker-compose.yml)
# deploy:
#   resources:
#     limits:
#       cpus: '1.5'
#       memory: 2G
#     reservations:
#       cpus: '0.5'
#       memory: 512M
```

## Emergency Procedures

```bash
# Full stack stop (everything down)
cd ~/home_media/ent
docker compose down

# Check health before restarting
docker compose ps -a
df -h /data
tailscale status

# Restart everything
docker compose up -d

# Verify recovery
docker compose ps
docker compose logs --tail=20
```

---

**Need help?** Check the [DEPLOYMENT.md](DEPLOYMENT.md) guide for full documentation.
