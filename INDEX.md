# Documentation Index

Complete guide to all documentation files. **Start here if you're new!**

---

## 🚀 Getting Started (Pick Your Path)

### Path 1: Quick Start (Existing Docker System)
**You already have Docker, Tailscale, and Linux set up**

1. Read: [README.md](README.md) - Overview of the stack
2. Clone: `git clone https://github.com/YOUR_USER/home_media.git`
3. Setup: Follow "Quick Start" in [README.md](README.md#quick-start)
4. Secure: Follow [SECURITY.md](SECURITY.md#initial-setup-checklist)
5. Monitor: Run `./health_check.sh` to verify everything

**Time**: ~30 minutes

---

### Path 2: Full Production Setup (Fresh Server)
**You have a bare Linux server and need everything**

1. Read: [DEPLOYMENT.md](DEPLOYMENT.md) - Complete system setup
   - System preparation (Docker, Tailscale, UFW)
   - Clone and configure
   - Launch and verify
   - Health monitoring

2. Then follow Path 1 (Security setup)

**Time**: ~1-2 hours

---

### Path 3: Quick Reference (Already Running)
**Your stack is up, you need commands**

- [COMMANDS.md](COMMANDS.md) - Docker & Linux commands
- [health_check.sh](health_check.sh) - Automated health check script

**Usage**: 
```bash
chmod +x health_check.sh
./health_check.sh
```

---

## 📚 Documentation Files

### **README.md**
- What this stack is (12 services)
- Key features & architecture
- Security overview
- Quick start guide
- **Start here!**

### **DEPLOYMENT.md** ⭐ NEW - COMPREHENSIVE
Complete production deployment guide covering:
- **Part 1**: System Preparation
  - Docker Engine installation
  - Tailscale setup
  - UFW firewall configuration
  - Data directory creation

- **Part 2**: Repository Setup
  - Clone from GitHub (wget & git methods)
  - Environment configuration
  - Application data directories

- **Part 3**: Launch Stack
  - Starting services
  - Verification steps

- **Part 4**: Health Monitoring
  - Essential health check commands
  - Automated health check script
  - Resource monitoring

- **Part 5**: Post-Deployment
  - Service access methods
  - First-run checklist

- **Part 6**: Maintenance
  - Daily/Weekly/Monthly tasks
  - Quarterly backups

- **Part 7**: Troubleshooting
  - Common issues & solutions
  - Recovery procedures

- **Part 8**: Security Verification
- **Part 9**: Backup & Disaster Recovery

### **SECURITY.md**
Service-by-service security setup:
- Initial setup checklist for each app
- Authentication requirements
- API key management
- Inter-service integration guide
- Network architecture
- Monitoring & logs
- Maintenance schedule

**Read if you're setting up for the first time!**

### **SETUP.md**
Legacy setup guide (see DEPLOYMENT.md for fuller version):
- Prerequisites
- Installation steps
- Configuration options
- Initial verification

### **COMMANDS.md** ⭐ NEW - REFERENCE
Quick lookup for commands:
- **Docker Commands**: ps, logs, exec, stop, start, etc.
- **System Commands**: disk usage, permissions, networking
- **Troubleshooting Scenarios**: 
  - Container won't start
  - Services can't reach each other
  - Permission denied errors
  - Out of disk space
  - Tailscale not connecting
- **One-liners**: Quick health checks
- **Backup & Recovery**: Backup commands

**Bookmark this page!**

### **QUICKREF.md**
- Directory structure
- Essential files table
- Service access URLs
- Configuration commands
- Quick command reference

### **health_check.sh** ⭐ NEW - AUTOMATED
Executable bash script that runs automated health checks:
- Container status
- Disk space
- Network connectivity
- Tailscale integration
- Resource usage
- Error detection

**Run regularly:**
```bash
./health_check.sh
```

### **CHECKLIST.md** ⭐ NEW - PRINTABLE
Print-friendly deployment checklist covering:
- Pre-deployment system setup
- Repository setup
- Launch stack steps
- Security setup for each service
- Final verification
- Troubleshooting quick reference
- Maintenance notes

**Print this before deploying!**

---

## 🔍 Find Information By Topic

### Installation & Setup
- First time? → [DEPLOYMENT.md](DEPLOYMENT.md) (Part 1-3)
- Already have Docker? → [README.md](README.md#quick-start)
- Need help cloning? → [DEPLOYMENT.md](DEPLOYMENT.md#step-21-clone-from-github)

### Security & Authentication
- Which services need passwords? → [SECURITY.md](SECURITY.md#authentication-status)
- Step-by-step setup? → [SECURITY.md](SECURITY.md#initial-setup-checklist)
- API key locations? → [SECURITY.md](SECURITY.md#api-key-locations)
- First-run checklist? → [SECURITY.md](SECURITY.md#first-run-checklist)

### Docker & System Commands
- Need a command? → [COMMANDS.md](COMMANDS.md)
- One-liner health check? → [COMMANDS.md](COMMANDS.md#health-check-one-liners)
- Troubleshooting? → [COMMANDS.md](COMMANDS.md#troubleshooting-scenarios)
- Docker basics? → [COMMANDS.md](COMMANDS.md#essential-docker-commands)

### Monitoring & Health Checks
- Automated health check? → Run `./health_check.sh`
- Manual health checks? → [DEPLOYMENT.md](DEPLOYMENT.md#part-4-health-checks--monitoring)
- Monitor resources? → [COMMANDS.md](COMMANDS.md#process--system-monitoring)
- View logs? → [COMMANDS.md](COMMANDS.md#view-logs)

### Troubleshooting
- Container won't start? → [COMMANDS.md](COMMANDS.md#scenario-1-container-wont-start)
- Services can't talk? → [COMMANDS.md](COMMANDS.md#scenario-2-services-cant-reach-each-other)
- Permission errors? → [COMMANDS.md](COMMANDS.md#scenario-3-permission-denied-errors)
- Disk full? → [COMMANDS.md](COMMANDS.md#scenario-4-out-of-disk-space)
- Tailscale issues? → [COMMANDS.md](COMMANDS.md#scenario-5-tailscale-not-connecting)

### Maintenance
- Daily tasks? → [DEPLOYMENT.md](DEPLOYMENT.md#part-6-ongoing-maintenance)
- Backup strategy? → [DEPLOYMENT.md](DEPLOYMENT.md#part-9-backup--disaster-recovery)
- Update services? → [COMMANDS.md](COMMANDS.md#updaterebuild-stack)

### Network & Firewall
- UFW setup? → [DEPLOYMENT.md](DEPLOYMENT.md#step-15-configure-ufw-firewall)
- Security check? → [DEPLOYMENT.md](DEPLOYMENT.md#part-8-security-verification)
- Tailscale config? → [DEPLOYMENT.md](DEPLOYMENT.md#step-14-install-tailscale)

---

## 📋 Checklists

### Pre-Deployment Checklist
- [ ] Read [README.md](README.md)
- [ ] Understand architecture (12 services, Tailscale-only)
- [ ] Have Linux server ready
- [ ] Have Tailscale account
- [ ] Have GitHub account (or fork this repo)

### Deployment Checklist (Printable)
**Print [CHECKLIST.md](CHECKLIST.md)!** Contains:
- Pre-deployment tasks
- Package installation
- Docker setup
- Repository setup
- Launch stack
- Security setup per service
- Final verification
- Troubleshooting reference

### Security Setup Checklist
- [ ] Follow [SECURITY.md](SECURITY.md) Initial Setup Checklist
- [ ] Change qBittorrent password (CRITICAL)
- [ ] Set up Jellyfin user account
- [ ] Set up Plex account
- [ ] Configure Jellyseerr integrations
- [ ] Test request workflow

### Post-Launch Checklist
- [ ] Access Jellyseerr via Tailscale
- [ ] Request test movie
- [ ] Verify Radarr picks it up
- [ ] Monitor in qBittorrent
- [ ] Verify download appears in Jellyfin
- [ ] Set up backup strategy

---

## 🔗 External Resources

### Official Documentation
- **Docker Docs**: https://docs.docker.com/
- **Docker Compose**: https://docs.docker.com/compose/
- **Tailscale Docs**: https://tailscale.com/kb/

### Service Documentation
- **Radarr**: https://radarr.video/
- **Sonarr**: https://sonarr.tv/
- **Lidarr**: https://lidarr.audio/
- **Readarr**: https://readarr.com/
- **Jellyfin**: https://docs.jellyfin.org/
- **Jellyseerr**: https://docs.jellyseerr.dev/
- **Plex**: https://support.plex.tv/
- **qBittorrent**: https://www.qbittorrent.org/
- **Prowlarr**: https://wiki.servarr.com/prowlarr/

### Community
- **Servarr Discord**: https://discord.gg/servarr
- **Jellyfin Forums**: https://jellyfin.org/
- **r/selfhosted**: https://reddit.com/r/selfhosted

---

## 💡 Tips & Best Practices

### Security
✅ **DO**:
- Keep .env file secret (it's in .gitignore)
- Use Tailscale for all access (no port forwarding)
- Change default passwords immediately
- Monitor access logs regularly

❌ **DON'T**:
- Expose services to the internet
- Share Tailscale access broadly
- Keep default passwords
- Commit .env to git

### Performance
✅ **DO**:
- Monitor disk usage weekly
- Set up automated backups
- Check logs for errors
- Update images monthly

❌ **DON'T**:
- Run with insufficient disk space
- Ignore error logs
- Forget to backup configs
- Let media library grow unmanaged

### Maintenance
✅ **DO**:
- Run `./health_check.sh` weekly
- Keep docker images updated
- Document custom configs
- Test recovery procedures

❌ **DON'T**:
- Stop containers abruptly (use compose down)
- Delete appdata without backup
- Run as root unnecessarily
- Ignore Tailscale connection issues

---

## 🆘 Need Help?

1. **First check**: Run `./health_check.sh` to identify issues
2. **Check logs**: `docker compose logs -f service_name`
3. **Search docs**: Look in [COMMANDS.md](COMMANDS.md) troubleshooting section
4. **Read setup guide**: Follow exact steps in [SECURITY.md](SECURITY.md)
5. **Check networks**: Verify `docker network ls` shows `arr_network`

---

## 📄 File Reference

| File | Purpose | When to Read |
|------|---------|--------------|
| [README.md](README.md) | Overview & quick start | First! |
| [DEPLOYMENT.md](DEPLOYMENT.md) | Full production setup | Fresh server |
| [SECURITY.md](SECURITY.md) | Service authentication | First-time setup |
| [SETUP.md](SETUP.md) | Basic setup (legacy) | Reference |
| [COMMANDS.md](COMMANDS.md) | Docker & Linux commands | Need a command |
| [QUICKREF.md](QUICKREF.md) | Quick lookup | Quick lookup |
| [CHECKLIST.md](CHECKLIST.md) | Deployment checklist | Print & use during setup |
| [health_check.sh](health_check.sh) | Health checks | Regular monitoring |
| [.env.example](.env.example) | Configuration template | Setup time |
| [.gitignore](.gitignore) | Git security | Reference |
| [docker-compose.yml](ent/docker-compose.yml) | Stack definition | Reference |

---

## 🗓️ Recommended Reading Order

### For Complete Beginners
1. [README.md](README.md) - 5 min
2. [DEPLOYMENT.md](DEPLOYMENT.md) - 30 min (skim Part 1-3)
3. [SECURITY.md](SECURITY.md) - 15 min (follow checklist)
4. Run `./health_check.sh` - 2 min
5. Bookmark [COMMANDS.md](COMMANDS.md) - Reference

### For Experienced Self-Hosters
1. [README.md](README.md) - 5 min (overview)
2. [DEPLOYMENT.md](DEPLOYMENT.md) Part 1 - 10 min (UFW/Tailscale review)
3. [SECURITY.md](SECURITY.md) - 10 min (setup checklist)
4. Bookmark [COMMANDS.md](COMMANDS.md) - Reference

### For Maintenance
- Weekly: Run `./health_check.sh`
- Monthly: Check [DEPLOYMENT.md](DEPLOYMENT.md) Part 6 maintenance tasks
- Quarterly: Review [SECURITY.md](SECURITY.md) checklist

---

**Last Updated**: February 14, 2026  
**Status**: Production-Ready  
**Next**: Start with [README.md](README.md) or [DEPLOYMENT.md](DEPLOYMENT.md) depending on your setup!
