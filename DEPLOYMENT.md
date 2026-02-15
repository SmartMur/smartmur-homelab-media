# Production Deployment Guide

Complete guide for deploying the Home Media Server stack on a fresh Linux system with Docker, firewall security, and health monitoring.

---

## Part 1: System Preparation (Fresh Linux Server)

### Prerequisites
- Ubuntu 20.04 LTS or later (or similar Debian-based distro)
- Minimum 4GB RAM, 20GB storage (more for large media libraries)
- SSH access to server
- Sudo privileges
- Tailscale account (free tier acceptable)

### Step 1.1: Update System

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y wget curl git ca-certificates
```

### Step 1.2: Install Docker Engine

```bash
# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Verify installation
docker --version
docker compose version
```

### Step 1.3: Add User to Docker Group

```bash
# Add current user to docker group
sudo usermod -aG docker $USER

# Apply group changes
newgrp docker

# Verify (should work without sudo)
docker ps
```

### Step 1.4: Install Tailscale

```bash
# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Start Tailscale
sudo tailscale up

# Get your Tailscale IP
tailscale ip -4

# Enable IP forwarding (if hosting multiple devices)
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

### Step 1.5: Configure UFW Firewall

```bash
# Enable UFW
sudo ufw enable

# Allow SSH (CRITICAL - do this first to avoid lockout)
sudo ufw allow 22/tcp

# Allow only Tailscale (no Docker ports exposed)
# Services only accessible via Tailscale VPN
sudo ufw default deny incoming
sudo ufw default allow outgoing

# View firewall status
sudo ufw status

# Result should show:
# Status: active
# Default: deny (incoming), allow (outgoing)
# 22/tcp ALLOW Anywhere
```

**Key Principle**: Since all services are behind Tailscale, UFW just needs to allow SSH and block everything else.

### Step 1.6: Create Data Directories

```bash
# Create media structure
sudo mkdir -p /data/media/{movies,tv,music,books}
sudo mkdir -p /data/torrents/{movies,tv,music,books}

# Set permissions (use your actual UID:GID)
sudo chown -R 1000:1000 /data
sudo chmod -R 755 /data

# Verify
ls -la /data/
```

---

## Part 2: Clone and Configure Repository

### Step 2.1: Clone from GitHub

```bash
# Clone the repository
cd ~
wget https://github.com/YOUR_USERNAME/home_media/archive/main.zip
unzip main.zip
mv home_media-main home_media
cd home_media

# Alternative: Direct git clone (if GitHub SSH is configured)
# git clone https://github.com/YOUR_USERNAME/home_media.git
# cd home_media
```

### Step 2.2: Setup Environment File

```bash
# Copy example to actual config
cp .env.example .env

# Edit with your values
nano .env

# Required settings to update:
# PUID=1000 # Run: id -u
# PGID=1000 # Run: id -g
# TZ=America/Toronto # Your timezone
# TSDPROXY_AUTHKEY=... # From https://login.tailscale.com/admin/settings/keys
# TSDPROXY_HOSTNAME=... # From: tailscale ip -4
# PLEX_CLAIM_TOKEN=... # From: https://www.plex.tv/claim/ (optional, 4min lifespan)
```

### Step 2.3: Prepare Application Data Directories

```bash
cd ent/

# Create appdata directories for all services
mkdir -p appdata/{radarr,sonarr,lidarr,readarr,prowlarr,qbittorrent,jellyfin,jellyseerr,bazarr,plex,dockhand,termix}

# Set permissions
chmod -R 775 appdata/
```

---

## Part 3: Launch the Stack

### Step 3.1: Start Services

```bash
cd ~/home_media/ent/

# Pull latest images
docker compose pull

# Start stack in background
docker compose up -d

# Check status
docker compose ps
```

**Expected output:**
```
NAME COMMAND STATUS PORTS
radarr "/init" Up 2 minutes
sonarr "/init" Up 2 minutes
lidarr "/init" Up 2 minutes
readarr "/init" Up 2 minutes
prowlarr "/init" Up 2 minutes
qbittorrent "/init" Up 2 minutes
jellyfin "/init" Up 2 minutes
jellyseerr "node server.js" Up 2 minutes
plex "/init" Up 2 minutes
bazarr "/init" Up 2 minutes
tsdproxy "/app/tsdproxy" Up 2 minutes
termix "node server.js" Up 2 minutes
dockhand "node /app/index" Up 2 minutes
```

### Step 3.2: Verify Tailscale Connection

```bash
# Check TSDProxy logs
docker compose logs -f tsdproxy

# Should see:
# Connected to Tailscale
# Proxying requests...

# Exit logs with Ctrl+C
```

---

## Part 4: Health Checks & Monitoring

### Command Reference: Essential Health Checks

```bash
# ===== BASIC HEALTH =====

# All services running?
docker compose ps

# Any errors in startup?
docker compose logs --tail=20

# Specific service logs
docker compose logs -f radarr
docker compose logs -f jellyfin
docker compose logs -f qbittorrent

# ===== SERVICE CONNECTIVITY =====

# Verify services can reach each other (exec into a container)
docker compose exec radarr ping sonarr
docker compose exec jellyseerr ping radarr
docker compose exec radarr ping qbittorrent

# ===== DISK & RESOURCES =====

# Check disk usage
df -h /data/
df -h ~/home_media/

# Docker resource usage
docker stats

# Container resource limits (none set = good, means no restrictions)
docker inspect radarr | grep -A 5 "Memory"

# ===== NETWORK =====

# Check if ports are NOT exposed to internet (should be empty)
sudo netstat -tlnp | grep -E "(8080|8096|8989|7878|8686|6767)"

# Or using ss (newer systems)
sudo ss -tlnp | grep docker

# Should show NO external bindings, only localhost/internal

# ===== VOLUME MOUNTS =====

# Verify data directory is accessible
docker compose exec radarr ls -la /data/media/
docker compose exec jellyfin ls -la /data/media/movies

# ===== TAILSCALE =====

# Verify Tailscale is running on host
tailscale status

# Check if TSDProxy can see Docker
docker compose exec tsdproxy docker ps

# List Tailscale network devices
sudo tailscale status
```

### Automated Health Check Script

Create `/home/lab/home_media/health_check.sh`:

```bash
#!/bin/bash

echo "=== HOME MEDIA SERVER HEALTH CHECK ==="
echo ""

cd ~/home_media/ent/

# 1. Container Status
echo "[1] Container Status:"
docker compose ps | tail -n +2 | while read line; do
 if [[ $line == *"Up"* ]]; then
 echo " $(echo $line | awk '{print $1}') is running"
 else
 echo " $(echo $line | awk '{print $1}') is DOWN"
 fi
done

echo ""

# 2. Storage Space
echo "[2] Storage Space:"
USED=$(df /data | awk 'NR==2 {print $3}')
TOTAL=$(df /data | awk 'NR==2 {print $2}')
PERCENT=$(df /data | awk 'NR==2 {print $5}')
echo " Used: $USED / $TOTAL ($PERCENT)"

if [[ ${PERCENT%\%} -gt 80 ]]; then
 echo " Warning: Disk usage above 80%"
fi

echo ""

# 3. Network Connectivity
echo "[3] Network Connectivity:"
if timeout 2 docker compose exec radarr ping -c 1 qbittorrent > /dev/null 2>&1; then
 echo " Radarr → qBittorrent: OK"
else
 echo " Radarr → qBittorrent: FAILED"
fi

if timeout 2 docker compose exec jellyseerr ping -c 1 radarr > /dev/null 2>&1; then
 echo " Jellyseerr → Radarr: OK"
else
 echo " Jellyseerr → Radarr: FAILED"
fi

echo ""

# 4. Tailscale Status
echo "[4] Tailscale Connection:"
if sudo tailscale status | grep -q "Running"; then
 echo " Tailscale: Running"
else
 echo " Tailscale: NOT running"
fi

if docker compose logs tsdproxy | grep -q "Connected"; then
 echo " TSDProxy: Connected"
else
 echo " TSDProxy: Connection check - see logs"
fi

echo ""
echo "=== END HEALTH CHECK ==="
```

Make it executable:
```bash
chmod +x ~/home_media/health_check.sh

# Run anytime
~/home_media/health_check.sh
```

---

## Part 5: Post-Deployment Configuration

### Access Your Services

1. **Get your Tailscale IP:**
 ```bash
 tailscale ip -4
 # Example: 100.123.45.67
 ```

2. **Access services:**
 - Jellyseerr (setup first): `https://100.123.45.67:port` (TSDProxy handles routing)
 - Radarr: `https://100.123.45.67:port`
 - Sonarr: `https://100.123.45.67:port`
 - etc.

3. **Follow security setup:** See [SECURITY.md](SECURITY.md) for authentication steps per service

### First-Run Checklist

- [ ] All containers running (`docker compose ps`)
- [ ] Disk space available (`df -h /data`)
- [ ] Tailscale connected (`tailscale status`)
- [ ] TSDProxy connected (`docker compose logs tsdproxy`)
- [ ] Access Jellyseerr via Tailscale
- [ ] Set up Jellyfin user account
- [ ] Set up Plex (claim token or account)
- [ ] Change qBittorrent admin password
- [ ] Configure Jellyseerr integrations (Radarr, Sonarr, etc.)
- [ ] Test request workflow (request movie in Jellyseerr)

---

## Part 6: Ongoing Maintenance

### Daily Checks (5 min)

```bash
# Status
docker compose ps

# Recent errors?
docker compose logs --tail=50 | grep -i error
```

### Weekly Tasks

```bash
# View space usage
du -sh /data/media/*

# Check for stuck downloads
docker compose exec qbittorrent find /data/torrents -type f -mtime +7 -ls

# Review Radarr/Sonarr logs for errors
docker compose logs --tail=100 radarr | grep -i error
docker compose logs --tail=100 sonarr | grep -i error
```

### Monthly Tasks

```bash
# Update all images to latest versions
docker compose pull
docker compose up -d

# Check for disk issues
docker exec radarr df -h /data/

# Review Jellyfin library health
# Via web UI: Admin → Dashboard → Libraries
```

### Quarterly Tasks

```bash
# Full backup of appdata
tar -czf ~/appdata_backup_$(date +%Y%m%d).tar.gz ~/home_media/ent/appdata/

# Prune unused Docker resources
docker system prune -a --volumes

# Review Tailscale devices
tailscale status
```

---

## Part 7: Troubleshooting

### Container Won't Start

```bash
# Check logs
docker compose logs service_name

# Common issues:
# - Port already in use (shouldn't happen with Tailscale-only)
# - Volume permission denied (check appdata/ ownership)
# - Image pull failed (network issue, retry: docker compose pull)
```

### Services Can't Reach Each Other

```bash
# Test connectivity
docker compose exec radarr ping sonarr

# If fails:
# 1. Verify both containers running: docker compose ps
# 2. Check network: docker network ls
# 3. Verify network name in compose file: arr_network
```

### TSDProxy Not Connecting

```bash
# Check logs
docker compose logs tsdproxy

# Verify TSDPROXY_AUTHKEY is valid
cat .env | grep TSDPROXY_AUTHKEY

# Auth key must be freshly generated at:
# https://login.tailscale.com/admin/settings/keys
```

### Disk Space Issues

```bash
# Find large files
find /data -size +10G -type f

# Check what's consuming space
du -sh /data/* | sort -rh

# Clean up old torrents
docker compose exec qbittorrent find /data/torrents -type f -mtime +30 -delete

# Note: Never delete /data/media without backing up!
```

---

## Part 8: Security Verification

```bash
# Confirm NO ports exposed to internet
sudo netstat -tlnp | grep docker

# Should show NOTHING or only loopback
# (All services behind Tailscale via TSDProxy)

# Verify UFW is denying outside access
sudo ufw status detailed

# Check SSH is on standard port 22 (not exposed beyond UFW allow)
sudo ss -tlnp | grep ssh
```

---

## Part 9: Backup & Disaster Recovery

### Backup Strategy

**Critical data to backup:**
1. `/data/media` - Your media files (if not backed up elsewhere)
2. `~/home_media/ent/appdata/` - Service configurations
3. `.env` - Your secrets (never commit, backup separately)

```bash
# Full backup (daily via cron)
BACKUP_DIR="/backup/home_media"
mkdir -p $BACKUP_DIR

# Backup appdata
tar -czf $BACKUP_DIR/appdata_$(date +%Y%m%d_%H%M%S).tar.gz \
 ~/home_media/ent/appdata/

# Backup .env (encrypted)
gpg --symmetric .env -o $BACKUP_DIR/.env.gpg

# Backup media library structure
tar -czf $BACKUP_DIR/media_structure_$(date +%Y%m%d).tar.gz \
 /data/ --exclude=/data/torrents

# Cleanup old backups (keep 30 days)
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete
```

### Automated Backup (Cron)

```bash
# Add to crontab
crontab -e

# Daily backup at 2 AM
0 2 * * * /home/lab/home_media/backup.sh >> /var/log/home_media_backup.log 2>&1
```

### Recovery Procedure

```bash
# Stop stack
docker compose down

# Restore appdata
tar -xzf appdata_YYYYMMDD_HHMMSS.tar.gz -C ~/home_media/ent/

# Restore .env (if lost)
gpg --decrypt .env.gpg > .env

# Restart
docker compose up -d

# Verify
docker compose ps
```

---

## Quick Reference: Essential Commands

```bash
# Navigate to stack
cd ~/home_media/ent/

# View everything
docker compose ps # All containers
docker compose logs -f # All logs
docker compose logs -f service_name # Specific service

# Control
docker compose up -d # Start all
docker compose down # Stop all
docker compose restart service_name # Restart one
docker compose pull && docker compose up -d # Update everything

# Debug
docker compose exec service_name bash # Enter container
docker compose exec service_name df -h /data # Check disk in container
docker compose logs --tail=50 service_name # Last 50 lines

# System
df -h /data # Disk usage
docker stats # Resource usage
tailscale status # Tailscale connection
```

---

## Support & Documentation Links

- **Official Docs**: See README.md, SECURITY.md, SETUP.md
- **Docker Docs**: https://docs.docker.com/
- **Tailscale Docs**: https://tailscale.com/kb/
- **Service Documentation**:
 - Radarr: https://radarr.video/
 - Sonarr: https://sonarr.tv/
 - Jellyfin: https://docs.jellyfin.org/
 - Plex: https://support.plex.tv/

---

**Last Updated**: February 14, 2026
**Status**: Production-Ready
