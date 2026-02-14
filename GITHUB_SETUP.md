# GitHub Setup Instructions

Your local repository is ready! Follow these steps to connect to GitHub.

## Step 1: Create Repository on GitHub

1. Go to https://github.com/new
2. Repository name: `home_media` (or your preferred name)
3. Description: "Production-ready self-hosted media server stack with Tailscale security"
4. **Choose visibility**: 
   - ✅ **PUBLIC** - Share with community (recommended, no secrets exposed)
   - 🔒 Private - If you prefer
5. **DO NOT initialize** with README, .gitignore, or license (we already have them)
6. Click "Create repository"

## Step 2: Connect Local Repository to GitHub

You'll see instructions on GitHub. Use these commands:

```bash
cd ~/home_media

# Add GitHub remote
git remote add origin https://github.com/YOUR_USERNAME/home_media.git

# Rename branch to main (optional but recommended)
git branch -m master main

# Push to GitHub
git push -u origin main
```

**Replace `YOUR_USERNAME` with your actual GitHub username!**

## Step 3: Verify on GitHub

- Visit: https://github.com/YOUR_USERNAME/home_media
- Confirm you see:
  - ✅ All documentation files (README.md, DEPLOYMENT.md, etc.)
  - ✅ Docker compose files
  - ✅ health_check.sh script
  - ❌ NO .env file (should be hidden)
  - ❌ NO appdata/ folders (should be hidden)

## Step 4: Add GitHub Files (Optional but Recommended)

Create these files on GitHub for better visibility:

### .github/CODEOWNERS
```
* @YOUR_USERNAME
```

### .github/ISSUE_TEMPLATE/bug_report.md
```
**Describe the bug**
<!-- Your description -->

**Environment**
- OS: Ubuntu 20.04+ / Debian / Other
- Docker: 
- Tailscale: Yes/No

**Steps to reproduce**
1. Follow DEPLOYMENT.md
2. Run health_check.sh
3. See error...
```

### .github/ISSUE_TEMPLATE/feature_request.md
```
**Is your feature request related to a problem?**
<!-- Your description -->

**Suggested implementation**
<!-- How this could work -->
```

## Step 5: Add Repository Topics (GitHub Page)

On your repository page:
1. Click "⚙️ Settings"
2. Scroll to "Topics"
3. Add tags for discovery:
   - `self-hosted`
   - `docker`
   - `media-server`
   - `tailscale`
   - `radarr`
   - `sonarr`
   - `jellyfin`
   - `plex`

## Step 6: Update README Links

Update references in [README.md](../README.md) from:
```
git clone <your-repository-url>
```

To:
```
git clone https://github.com/YOUR_USERNAME/home_media.git
```

Also update in [DEPLOYMENT.md](../DEPLOYMENT.md):
```
wget https://github.com/YOUR_USERNAME/home_media/archive/main.zip
```

## Future Updates

To push updates:

```bash
cd ~/home_media

# Make changes
nano README.md  # or edit any file

# Commit
git add .
git commit -m "Your clear commit message"

# Push to GitHub
git push origin main
```

## Security Verification

Before making public, verify:

```bash
# Check what would be committed
git status

# Verify .env is ignored
git check-ignore .env
# Should output: .env

# Verify appdata is ignored
git check-ignore ent/appdata
# Should output: ent/appdata

# View what's actually in the repo
git ls-files | head -20
```

## README Badge (Optional)

Add this to the top of your README.md to show the repo status:

```markdown
[![GitHub Release](https://img.shields.io/github/v/release/YOUR_USERNAME/home_media?style=flat-square)](https://github.com/YOUR_USERNAME/home_media/releases)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](https://github.com/YOUR_USERNAME/home_media/blob/main/LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Compose-blue?style=flat-square)](https://docs.docker.com/compose/)
[![Tailscale](https://img.shields.io/badge/Tailscale-Secure-green?style=flat-square)](https://tailscale.com/)
```

## Share & Promote

Once live, you can share:

- **Direct link**: https://github.com/YOUR_USERNAME/home_media
- **Raw README**: https://github.com/YOUR_USERNAME/home_media/blob/main/README.md
- **Deployment guide**: https://github.com/YOUR_USERNAME/home_media/blob/main/DEPLOYMENT.md
- **Share on**: 
  - r/selfhosted
  - r/homeserver
  - Hacker News
  - Twitter/X
  - Discord servers (Servarr, Jellyfin, etc.)

## License (Optional)

To add a license:

1. On GitHub, click "Add file" → "Create new file"
2. Name: `LICENSE`
3. GitHub provides templates (MIT recommended for open-source)
4. Commit

Or locally:
```bash
# Create MIT LICENSE file
echo "MIT License - see LICENSE file for details" > LICENSE
git add LICENSE
git commit -m "Add MIT LICENSE"
git push origin main
```

## Questions?

If you encounter issues:
1. Check [DEPLOYMENT.md](../DEPLOYMENT.md) Part 7 (Troubleshooting)
2. Review [INDEX.md](../INDEX.md) for documentation
3. Open a GitHub Issue on your repository

---

**Repository Status**: ✅ Ready for GitHub  
**Security Level**: 🔒 All secrets protected  
**Documentation**: 📚 Complete (3,110+ lines)  
**Next**: Push to GitHub and share with the community!
