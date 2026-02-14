# Home Media Server - Self-Hosted Media Management Stack

Production-ready Docker Compose setup for a complete, secure, self-hosted media server with automatic downloads, organization, and streaming.

![Stack: Complete](https://img.shields.io/badge/Stack-Complete-brightgreen)
![Security: Configured](https://img.shields.io/badge/Security-Hardened-blue)
![License: MIT](https://img.shields.io/badge/License-MIT-green)

## 🎬 What You Get

A complete self-hosted media management ecosystem with 10 services:

- **Radarr** - Automated movie management and downloads
- **Sonarr** - Automated TV show management and downloads
- **Lidarr** - Automated music management and downloads
- **Prowlarr** - Centralized torrent/usenet indexer manager
- **Bazarr** - Automatic subtitle downloading
- **qBittorrent** - Torrent client for downloads
- **Jellyfin** - Open-source media streaming server
- **Termix** - Web-based terminal for remote admin
- **Dockhand** - Docker container management UI
- **TSDProxy** - Tailscale-based secure reverse proxy

All services are **pre-configured** with Trash Guides media organization standard.

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose
- 20GB+ free disk space
- Tailscale account (free)
- Linux system (Ubuntu 20.04+ recommended)

### Deploy in 5 Minutes

```bash
# 1. Clone repository
git clone https://github.com/YOUR_USERNAME/home-media-server.git
cd home-media-server

# 2. Configure secrets
cp .env.example .env
nano .env  # Fill in Tailscale auth key and hostname

# 3. Prepare data directories
mkdir -p /data/media/{movies,tv,music}
mkdir -p /data/torrents/{movies,tv,music}

# 4. Start the stack
cd ent/
docker-compose up -d

# 5. Access services
# Local: http://localhost:7878 (Radarr)
# Remote: https://radarr.your-tailscale-hostname (via Tailscale)
```

See **[DEPLOYMENT.md](.github/DEPLOYMENT.md)** for detailed setup instructions.

## 📖 Documentation

- **[README.md](README.md)** - Overview and repository structure
- **[SETUP.md](SETUP.md)** - Comprehensive setup guide (770+ lines)
- **[DEPLOYMENT.md](.github/DEPLOYMENT.md)** - GitHub deployment instructions
- **[QUICKREF.md](QUICKREF.md)** - Quick reference for common commands

## 🔐 Security

This repository follows security best practices:

✅ **No hardcoded secrets** - All sensitive values in `.env` (excluded from git)
✅ **Environment variables** - Docker Compose uses `${VAR}` substitution
✅ **Comprehensive .gitignore** - Prevents accidental secret commits
✅ **Tailscale integration** - VPN-based access, no port forwarding needed
✅ **Volume isolation** - Application data separated from configuration

**Important**: Never commit your `.env` file to git!

## 📁 Structure

```
home-media-server/
├── ent/                              # Main media server stack
│   ├── docker-compose.yml            # 10 services definition
│   └── appdata/                      # Config volumes
├── dockhand/                         # Docker UI (optional)
├── tails/                            # Utilities (optional)
├── termix/                           # Web terminal (optional)
├── .env.example                      # Configuration template
├── .gitignore                        # Prevent secret commits
├── README.md                         # Overview
├── SETUP.md                          # Setup guide
├── QUICKREF.md                       # Command reference
└── .github/
    └── DEPLOYMENT.md                 # Deployment guide
```

## 🎯 Key Features

### Pre-Configured Services
All services are configured to work together out-of-the-box:
- Prowlarr automatically discovers indexers
- *arr services connected to Prowlarr for indexer management
- qBittorrent configured with download categories
- Jellyfin ready for media streaming
- TSDProxy handles Tailscale integration

### Media Organization
Follows **Trash Guides** standard for consistent organization:
```
/data/media/
├── movies/           # Title (Year)/
├── tv/              # Series/Season NN/
└── music/           # Artist/Album (Year)/
```

### Secure Remote Access
- VPN-based via Tailscale (no port forwarding)
- TSDProxy reverse proxy integration
- Direct local access via Docker network

### Easy Deployment
- Single `docker-compose.yml` for entire stack
- Environment variable configuration
- Pre-configured volume mounts
- Automatic Tailscale integration

## 🔧 Services Overview

| Service | Purpose | Default Port | TSDProxy |
|---------|---------|--------------|----------|
| **Radarr** | Movie management | 7878 | radarr |
| **Sonarr** | TV show management | 8989 | sonarr |
| **Lidarr** | Music management | 8686 | lidarr |
| **Prowlarr** | Indexer manager | 9696 | prowlarr |
| **qBittorrent** | Torrent client | 8080 | qbittorrent |
| **Bazarr** | Subtitle manager | 6767 | bazarr |
| **Jellyfin** | Media streaming | 8096 | jellyfin |
| **Termix** | Web terminal | 8081 | termix |
| **Dockhand** | Docker UI | 3000 | dockhand |
| **TSDProxy** | Reverse proxy | - | - |

## 💾 Data Structure

```
/data/
├── media/                # Final organized media
│   ├── movies/          # Auto-organized by Radarr
│   ├── tv/              # Auto-organized by Sonarr
│   └── music/           # Auto-organized by Lidarr
└── torrents/            # Download staging
    ├── movies/
    ├── tv/
    └── music/
```

## 🛠️ Common Commands

```bash
# Start/stop the stack
docker-compose up -d
docker-compose down

# View logs
docker-compose logs -f radarr

# Update services
docker-compose pull && docker-compose up -d

# Backup configuration
tar -czf backup.tar.gz ent/appdata .env
```

See **[QUICKREF.md](QUICKREF.md)** for more commands.

## 🌍 Remote Access

Services are accessible via Tailscale at:
- `radarr.your-hostname.ts.net`
- `sonarr.your-hostname.ts.net`
- `jellyfin.your-hostname.ts.net`
- etc.

(Requires Tailscale installation on server and clients)

## 🔑 Configuration

All configuration is managed via `.env` file:

```bash
# System
PUID=1000
PGID=1000
TZ=America/Toronto

# Tailscale (required for remote access)
TSDPROXY_AUTHKEY=tskey-auth-XXXXX
TSDPROXY_HOSTNAME=your-ip-or-hostname

# Optional: Port overrides
QBITTORRENT_WEBUI_PORT=8080
JELLYFIN_PORT=8096
```

See `.env.example` for all available options.

## 📋 Requirements

- **Docker**: 20.10+
- **Docker Compose**: 2.0+
- **OS**: Linux (Ubuntu 20.04+ recommended)
- **RAM**: 4GB minimum (8GB+ recommended)
- **Storage**: 20GB+ (depends on media size)
- **Network**: Internet connection

## 🐛 Troubleshooting

### Services won't start?
```bash
docker-compose logs
docker-compose ps
```

### Permission errors?
```bash
sudo chown -R 1000:1000 ent/appdata
sudo chown -R 1000:1000 /data
```

### Can't access remotely?
- Verify Tailscale is running: `tailscale status`
- Check TSDProxy logs: `docker-compose logs tsdproxy`
- See DEPLOYMENT.md for detailed troubleshooting

For more help, see **[SETUP.md](SETUP.md)**.

## 📚 Detailed Guides

- **First time setup?** → [DEPLOYMENT.md](.github/DEPLOYMENT.md)
- **Need detailed instructions?** → [SETUP.md](SETUP.md)
- **Just need quick commands?** → [QUICKREF.md](QUICKREF.md)

## 🤝 Contributing

Found an issue or have improvements? 
1. Check existing issues
2. Create a detailed bug report or feature request
3. Submit a pull request

## 📄 License

[MIT License](LICENSE) - Use freely for personal use

## 🙏 Credits

Built with:
- [Radarr](https://radarr.video/)
- [Sonarr](https://sonarr.tv/)
- [Lidarr](https://lidarr.audio/)
- [Jellyfin](https://jellyfin.org/)
- [qBittorrent](https://www.qbittorrent.org/)
- [Tailscale](https://tailscale.com/)

And many other open-source projects.

---

**Ready to start?** Follow the [Quick Start](#-quick-start) above, or see [DEPLOYMENT.md](.github/DEPLOYMENT.md) for detailed instructions.

**Questions?** Check [SETUP.md](SETUP.md) for comprehensive documentation.

**Want a cheat sheet?** See [QUICKREF.md](QUICKREF.md).
