# Deployment Checklist - Print This!

Quick reference checklist for deploying the Home Media Server stack.

---

## 🔧 PRE-DEPLOYMENT (Fresh Linux Server)

### System Preparation
- [ ] Ubuntu 20.04+ installed
- [ ] SSH access configured
- [ ] 4GB+ RAM available
- [ ] 20GB+ disk space available

### Package Installation
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y wget curl git ca-certificates
```
- [ ] System updated

### Docker Installation
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker
docker ps  # Should work without sudo
```
- [ ] Docker installed & working
- [ ] User added to docker group

### Tailscale Installation
```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```
- [ ] Tailscale installed
- [ ] Tailscale authenticated
- [ ] Tailscale IP noted: `_____________` (from `tailscale ip -4`)

### UFW Firewall
```bash
sudo ufw allow 22/tcp
sudo ufw enable
sudo ufw status  # Should show: active, Port 22/tcp allow
```
- [ ] UFW enabled
- [ ] SSH access allowed

### Data Directories
```bash
sudo mkdir -p /data/media/{movies,tv,music,books}
sudo mkdir -p /data/torrents/{movies,tv,music,books}
sudo chown -R 1000:1000 /data
sudo chmod -R 755 /data
```
- [ ] /data directories created
- [ ] Permissions set correctly

---

## 📦 REPOSITORY SETUP

### Clone Repository
```bash
cd ~
wget https://github.com/YOUR_USERNAME/home_media/archive/main.zip
unzip main.zip
mv home_media-main home_media
cd home_media
```
- [ ] Repository cloned
- [ ] In correct directory

### Configure Environment
```bash
cp .env.example .env
nano .env  # Edit these values:
```

**Required Values to Set:**
- [ ] PUID = _______ (from `id -u`)
- [ ] PGID = _______ (from `id -g`)
- [ ] TZ = _______ (your timezone)
- [ ] TSDPROXY_AUTHKEY = _______ (from https://login.tailscale.com/admin/settings/keys)
- [ ] TSDPROXY_HOSTNAME = _______ (your Tailscale IP)
- [ ] PLEX_CLAIM_TOKEN = _______ (from https://www.plex.tv/claim/, optional)

**Note**: Save the .env file. This is CRITICAL - never commit to git!

### Prepare Application Data
```bash
cd ent/
mkdir -p appdata/{radarr,sonarr,lidarr,readarr,prowlarr,qbittorrent,jellyfin,jellyseerr,bazarr,plex,dockhand,termix}
chmod -R 775 appdata/
```
- [ ] Application directories created
- [ ] Permissions set

---

## 🚀 LAUNCH STACK

### Start Services
```bash
docker compose pull
docker compose up -d
docker compose ps  # All containers should show "Up"
```
- [ ] All containers started
- [ ] All showing "Up" status

### Verify Tailscale Connection
```bash
docker compose logs tsdproxy
```
- [ ] TSDProxy connected message visible

### Quick Health Check
```bash
chmod +x ../health_check.sh
../health_check.sh
```
- [ ] Health check passes
- [ ] Containers responsive

---

## 🔐 SECURITY SETUP (Follow in Order)

### 1. qBittorrent (CRITICAL - Do First!)
```bash
# Access: https://YOUR_TAILSCALE_IP:port
# Default: admin / adminpass
```
- [ ] Logged in with default credentials
- [ ] Changed username and password
  - Tools → Options → Web UI → Authentication
  - ✅ "Require authentication" enabled
- [ ] Container restarted: `docker compose restart qbittorrent`

### 2. Jellyfin (Setup User Account)
```bash
# Access: https://YOUR_TAILSCALE_IP:port
```
- [ ] Initial setup wizard completed
- [ ] Admin account created
- [ ] Library paths configured
- [ ] Test: Can access and play media?

### 3. Jellyseerr (Request Interface)
```bash
# Access: https://YOUR_TAILSCALE_IP:port
```
- [ ] Setup wizard completed
- [ ] Jellyfin linked
- [ ] Radarr linked
- [ ] Sonarr linked
- [ ] User account created
- [ ] Test: Requested a movie?

### 4. Plex (If Using)
- [ ] Method A: Claim token in .env (recommended)
  - [ ] Plex account linked
  - [ ] Libraries visible
- [ ] OR Method B: Manual setup
  - [ ] Accessed via Tailscale
  - [ ] Account linked
  - [ ] Libraries configured

### 5. Radarr/Sonarr/Lidarr/Readarr (Optional Passwords)
```bash
# For each service:
# Settings → General → Security
# Set Authentication to "Basic" or "Forms"
```
- [ ] Radarr secured (optional but recommended)
- [ ] Sonarr secured (optional but recommended)
- [ ] Lidarr secured (optional but recommended)
- [ ] Readarr secured (optional but recommended)

### 6. Prowlarr (Indexers)
```bash
# Optional: Settings → General → Security
```
- [ ] Indexers added
- [ ] API key noted

### 7. Bazarr (Subtitles)
- [ ] Configured (if using)
- [ ] Linked to Radarr/Sonarr

---

## ✅ FINAL VERIFICATION

### Service Access Test
- [ ] Jellyseerr accessible via Tailscale
- [ ] Jellyfin accessible and can play video
- [ ] Radarr accessible
- [ ] Sonarr accessible
- [ ] Can request movie in Jellyseerr
- [ ] Radarr picked up request
- [ ] No "Port already in use" errors

### Network Security
```bash
sudo netstat -tlnp | grep docker
```
- [ ] NO services exposed to internet
- [ ] Only SSH (port 22) accessible

### Health Check
```bash
./health_check.sh
```
- [ ] All containers running
- [ ] All connectivity tests pass
- [ ] Tailscale connected
- [ ] Disk space OK

---

## 📚 DOCUMENTATION

### Bookmark These
- [ ] [INDEX.md](INDEX.md) - Documentation hub
- [ ] [COMMANDS.md](COMMANDS.md) - Docker commands
- [ ] [SECURITY.md](SECURITY.md) - Full security setup

### Regular Maintenance
- [ ] Weekly: Run `./health_check.sh`
- [ ] Monthly: Update images (`docker compose pull && docker compose up -d`)
- [ ] Quarterly: Backup appdata and .env

---

## 🆘 TROUBLESHOOTING

### Container Won't Start
1. Check logs: `docker compose logs service_name`
2. Verify permissions: `ls -la ent/appdata/`
3. Check disk space: `df -h /data`

### Services Can't Talk
1. Verify running: `docker compose ps`
2. Test ping: `docker compose exec radarr ping sonarr`
3. Check network: `docker network inspect arr_network`

### Tailscale Issues
1. Verify running: `sudo tailscale status`
2. Check TSDProxy: `docker compose logs tsdproxy`
3. Regenerate auth key at: https://login.tailscale.com/admin/settings/keys

### Disk Space
1. Check usage: `du -sh /data/* | sort -rh`
2. Remove old torrents: `find /data/torrents -type f -mtime +30 -delete`

---

## 📋 MAINTENANCE NOTES

### Things That Should NOT Be Exposed
- ✅ qBittorrent (Tailscale only)
- ✅ Jellyfin (Tailscale only)
- ✅ Radarr (Tailscale only)
- ✅ Sonarr (Tailscale only)
- ✅ Termix (Tailscale only)
- ✅ Dockhand (Tailscale only)

### Critical Files
- ⚠️ `.env` - NEVER commit to git (in .gitignore)
- ⚠️ `appdata/` - Contains configurations (in .gitignore)
- ✅ `.env.example` - Safe to commit
- ✅ Docker compose files - Safe to commit

### Emergency Contacts
- **Servarr Discord**: https://discord.gg/servarr
- **Jellyfin Forums**: https://jellyfin.org/
- **Tailscale Support**: https://support.tailscale.com/

---

## 📅 DEPLOYMENT DATE

**Date Started**: _____________  
**Date Completed**: _____________  
**System**: _______________ (Ubuntu version)  
**Tailscale IP**: _______________  
**Disk Capacity**: _______________  

---

**Print this checklist and keep it handy during deployment!**

For detailed information, see [INDEX.md](INDEX.md)
