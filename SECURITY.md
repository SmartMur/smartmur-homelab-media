# Security Configuration Guide

This stack prioritizes security with Tailscale-only access (no internet port exposure). Follow these steps for proper authentication setup.

## Initial Setup Checklist

### 1. qBittorrent (CRITICAL - Do First!)
**Default credentials are compromised if exposed**

1. Access: `https://qbittorrent.YOUR_TAILSCALE_IP`
2. Login with: `admin` / `adminpass`
3. **IMMEDIATELY** change password:
 - Tools → Options → Web UI
 - Set "Username" and "Password"
 - Check "Require authentication"
 - Apply and save
4. Restart container: `docker-compose restart qbittorrent`

### 2. Jellyfin (User Accounts)
**Requires initial setup for user management**

1. Access: `https://jellyfin.YOUR_TAILSCALE_IP`
2. First access shows setup wizard
3. Create your admin account
4. Configure library paths
5. Add additional users as needed
6. Set playback permissions in Admin → Users

### 3. Plex (Subscription Required)
**Requires active Plex subscription**

**Option A: Claim Token (Recommended)**
1. Visit: https://www.plex.tv/claim/ (valid for 4 minutes)
2. Copy the claim token
3. Add to .env: `PLEX_CLAIM_TOKEN=claim-XXXXXXXXX`
4. Restart: `docker-compose restart plex`
5. Access: `https://plex.YOUR_TAILSCALE_IP`

**Option B: Manual Account Linking**
1. Access: `https://plex.YOUR_TAILSCALE_IP`
2. Sign in with your Plex account
3. Complete setup wizard
4. Link libraries

### 3.5. Jellyseerr (Request/Discovery Interface)
**Integrates with Jellyfin, Radarr, Sonarr, Readarr**

1. Access: `https://jellyseerr.YOUR_TAILSCALE_IP`
2. First access shows setup wizard
3. Link Jellyfin instance:
 - Jellyfin URL: `http://jellyfin:8096` (internal Docker network)
 - API Key: Get from Jellyfin Admin → Dashboard → API Keys
4. Link Radarr:
 - Server URL: `http://radarr:7878`
 - API Key: Get from Radarr Settings → General
 - Quality Profile: Select your preferred quality
5. Link Sonarr:
 - Server URL: `http://sonarr:8989`
 - API Key: Get from Sonarr Settings → General
6. Create Jellyseerr user account for yourself
7. Share Jellyseerr link with family members who can request media

**Benefits:**
- Users request movies/shows without direct *arr access
- Automatic approval workflow (optional)
- Integrates requested items into Radarr/Sonarr

### 4. Radarr, Sonarr, Lidarr, Readarr (Recommended)
**No password required, but API key available**

**Recommended: Enable password protection**
1. Access: `https://sonarr.YOUR_TAILSCALE_IP` (same for Radarr/Lidarr/Readarr)
2. Settings → General → Security
3. Set "Authentication" to "Basic" or "Forms"
4. Create username/password
5. Repeat for each arr service
6. Note API key in Settings → General for integrations

### 5. Prowlarr (Recommended)
**Manages indexers and integrations**

1. Access: `https://prowlarr.YOUR_TAILSCALE_IP`
2. Settings → General → Security
3. Enable password: "Basic" or "Forms"
4. Create credentials
5. Add indexers via built-in settings

### 6. Bazarr (Optional)
**Subtitle manager**

1. Access: `https://bazarr.YOUR_TAILSCALE_IP`
2. Settings → Security (if available in your version)
3. Otherwise relies on Tailscale access only

### 7. Termix & Dockhand (Use with Caution)

** WARNING: These provide system-level access without built-in authentication**

**Secure Option 1: Disable in Production**
- Comment out or remove these services from docker-compose.yml if not needed
- Manage Docker via CLI instead

**Secure Option 2: Use Authelia Reverse Proxy** (Advanced)
- Add Authelia container for authentication layer
- Route Termix/Dockhand through Authelia before TSDProxy
- See example in Future Setup section below

**For Now: Minimum Security**
- Only connect Tailscale as authorized users
- Restrict access at firewall level if possible
- Monitor access logs regularly

## Inter-Service Integration

### Jellyseerr Configuration (First!)
1. **Link Jellyfin**: Settings → Jellyfin
 - URL: `http://jellyfin:8096`
 - API Key: Get from Jellyfin Admin → Dashboard
2. **Link Radarr**: Settings → Services → Radarr
 - URL: `http://radarr:7878`
 - API Key: Get from Radarr Settings → General
3. **Link Sonarr**: Settings → Services → Sonarr
 - URL: `http://sonarr:8989`
 - API Key: Get from Sonarr Settings → General
4. **Link Readarr**: Settings → Services → Readarr
 - URL: `http://readarr:8787`
 - API Key: Get from Readarr Settings → General
5. Create user account for yourself

### Prowlarr → Radarr/Sonarr/Lidarr/Readarr
1. In Prowlarr: Settings → Apps
2. Add each arr service:
 - Sync Level: Add and Remove
 - Server: `http://radarr:7878` (internal Docker network)
 - API Key: Get from each app's Settings → General
3. Test connection

### qBittorrent → Radarr/Sonarr/Lidarr/Readarr
1. In each arr app: Settings → Download Clients
2. Add qBittorrent:
 - Host: `qbittorrent` (Docker network)
 - Port: `8080` (internal)
 - Username: qBittorrent UI credentials
 - Test connection

### Bazarr → Radarr/Sonarr
1. In Bazarr: Settings → Sonarr / Radarr
2. Enable integration
3. Set Sonarr URL: `http://sonarr:8989`
4. Set Radarr URL: `http://radarr:7878`
5. Add API keys

## API Key Locations

| Service | Location | Purpose |
|---------|----------|---------|
| Radarr | Settings → General → API Key | Integrations (Prowlarr, Jellyseerr, etc) |
| Sonarr | Settings → General → API Key | Integrations |
| Lidarr | Settings → General → API Key | Integrations |
| Readarr | Settings → General → API Key | Integrations |
| Prowlarr | Settings → General → API Key | Testing, external apps |
| Jellyfin | Admin → Dashboard → API Keys | Jellyseerr, mobile apps |
| Plex | Settings → Remote Access | External sharing |

## Network Architecture

```
User's Device
 ↓ (Tailscale VPN)
Tailscale Network
 ↓
TSDProxy Container (Authentication via Tailscale)
 ↓
Internal arr_network (Docker)
 Radarr (port 7878)
 Sonarr (port 8989)
 Lidarr (port 8686)
 Readarr (port 8787)
 Jellyfin (port 8096)
 Plex (port 32400)
 Prowlarr (port 9696)
 qBittorrent (port 8080)
 Bazarr (port 6767)
 Termix (port 8080)
 Dockhand (port 3000)

NO PORTS EXPOSED TO INTERNET 
```

## Environment Variables Checklist

```bash
# Critical - Must set before first run
PUID=1000 # Your user ID
PGID=1000 # Your group ID
TZ=America/Toronto # Your timezone
TSDPROXY_AUTHKEY=tskey-auth-... # Tailscale auth (25min - must regenerate)
TSDPROXY_HOSTNAME=100.0.0.1 # Your Tailscale server IP
PLEX_CLAIM_TOKEN=claim-... # Plex claim token (optional, 4min lifespan)
```

## Monitoring & Logs

**View all service logs:**
```bash
cd ent/
docker-compose logs -f
```

**View specific service:**
```bash
docker-compose logs -f radarr
docker-compose logs -f qbittorrent
```

**Check TSDProxy connections:**
```bash
docker-compose logs tsdproxy
# Should see "Connected to Tailscale"
```

## Regular Maintenance

- **Weekly**: Check qBittorrent authentication is enforced
- **Monthly**: Review Tailscale device list (Settings → My devices)
- **Quarterly**: Update all container images (`docker-compose pull && docker-compose up -d`)
- **On Changes**: Update .env values (don't commit to git!)

## Troubleshooting Authentication Issues

**Q: Can't reach services via Tailscale**
- Verify Tailscale is running: `tailscale status`
- Check TSDProxy logs: `docker-compose logs tsdproxy`
- Confirm TSDPROXY_AUTHKEY is valid (regenerate if needed)

**Q: qBittorrent login rejected after password change**
- Restart container: `docker-compose restart qbittorrent`
- Wait 10 seconds for config to reload
- Retry login

**Q: Jellyfin shows no libraries**
- Check volume mounts: `docker-compose logs jellyfin`
- Verify /data/media exists on host
- Ensure PUID/PGID permissions allow access

**Q: Prowlarr → Radarr connection fails**
- Use internal Docker hostname: `http://radarr:7878`
- Verify API key is correct
- Check both containers are running: `docker-compose ps`
