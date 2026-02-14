#!/bin/bash

# Home Media Server - Health Check Script
# Run this regularly to monitor service health
# Usage: ./health_check.sh

set -e

cd "$(dirname "$0")/ent" || exit 1

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║    HOME MEDIA SERVER - HEALTH CHECK                          ║"
echo "║    $(date '+%Y-%m-%d %H:%M:%S')                                   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ===== 1. CONTAINER STATUS =====
echo "┌─ [1] CONTAINER STATUS"
echo ""

FAILED=0
docker compose ps --format "table {{.Names}}\t{{.Status}}" | tail -n +2 | while read -r name status; do
    if [[ $status == *"Up"* ]]; then
        printf "${GREEN}✓${NC} %-20s %s\n" "$name" "$status"
    else
        printf "${RED}✗${NC} %-20s %s\n" "$name" "$status"
        FAILED=$((FAILED + 1))
    fi
done

if [ $FAILED -eq 0 ]; then
    echo ""
    echo -e "${GREEN}All containers running${NC}"
else
    echo ""
    echo -e "${RED}$FAILED container(s) not running${NC}"
fi

echo ""

# ===== 2. STORAGE SPACE =====
echo "┌─ [2] STORAGE SPACE"
echo ""

DISK_INFO=$(df /data | tail -1)
USED=$(echo "$DISK_INFO" | awk '{print $3}')
TOTAL=$(echo "$DISK_INFO" | awk '{print $2}')
PERCENT=$(echo "$DISK_INFO" | awk '{print $5}' | sed 's/%//')

printf "  Total: %s GB\n" "$((TOTAL / 1024 / 1024))"
printf "  Used:  %s GB\n" "$((USED / 1024 / 1024))"
printf "  Usage: $PERCENT%%\n"

if [ "$PERCENT" -gt 80 ]; then
    printf "  ${RED}⚠ WARNING: Disk usage above 80%%${NC}\n"
elif [ "$PERCENT" -gt 90 ]; then
    printf "  ${RED}⚠ CRITICAL: Disk usage above 90%%${NC}\n"
else
    printf "  ${GREEN}✓ Disk space OK${NC}\n"
fi

echo ""

# ===== 3. DOCKER NETWORK =====
echo "┌─ [3] NETWORK CONNECTIVITY"
echo ""

# Test key connections
declare -A connections=(
    ["radarr→qbittorrent"]="radarr:qbittorrent"
    ["sonarr→qbittorrent"]="sonarr:qbittorrent"
    ["jellyseerr→radarr"]="jellyseerr:radarr"
    ["jellyfin→jellyseerr"]="jellyfin:jellyseerr"
)

for description in "${!connections[@]}"; do
    IFS=":" read -r from to <<< "${connections[$description]}"
    if timeout 2 docker compose exec "$from" ping -c 1 "$to" > /dev/null 2>&1; then
        printf "${GREEN}✓${NC} %s\n" "$description"
    else
        printf "${RED}✗${NC} %s (FAILED)\n" "$description"
    fi
done

echo ""

# ===== 4. VOLUME MOUNTS =====
echo "┌─ [4] DATA DIRECTORY ACCESS"
echo ""

# Test data mount
if docker compose exec radarr test -d /data/media > /dev/null 2>&1; then
    printf "${GREEN}✓${NC} /data/media is accessible\n"
else
    printf "${RED}✗${NC} /data/media is NOT accessible\n"
fi

if docker compose exec radarr test -d /data/torrents > /dev/null 2>&1; then
    printf "${GREEN}✓${NC} /data/torrents is accessible\n"
else
    printf "${RED}✗${NC} /data/torrents is NOT accessible\n"
fi

echo ""

# ===== 5. TAILSCALE & TSDPROXY =====
echo "┌─ [5] TAILSCALE INTEGRATION"
echo ""

# Check if Tailscale is running on host
if sudo tailscale status > /dev/null 2>&1; then
    printf "${GREEN}✓${NC} Tailscale is running\n"
    TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "unknown")
    printf "  IP: %s\n" "$TAILSCALE_IP"
else
    printf "${RED}✗${NC} Tailscale is NOT running\n"
fi

# Check TSDProxy connection
if docker compose logs --tail=50 tsdproxy 2>/dev/null | grep -q "Connected"; then
    printf "${GREEN}✓${NC} TSDProxy is connected to Tailscale\n"
else
    printf "${YELLOW}⚠${NC} TSDProxy connection status uncertain\n"
    printf "  (Run: docker compose logs tsdproxy)\n"
fi

echo ""

# ===== 6. RESOURCE USAGE =====
echo "┌─ [6] RESOURCE USAGE (Top 3)"
echo ""

echo "Memory & CPU:"
docker stats --no-stream --format "table {{.Container}}\t{{.MemUsage}}\t{{.CPUPerc}}" | tail -n +2 | head -3 | awk '{printf "  %-15s %s  %s\n", $1, $2, $3}'

echo ""

# ===== 7. ERROR CHECK =====
echo "┌─ [7] RECENT ERRORS (Last 20 log lines)"
echo ""

ERROR_COUNT=$(docker compose logs --tail=100 2>/dev/null | grep -i "error" | wc -l)

if [ "$ERROR_COUNT" -eq 0 ]; then
    printf "${GREEN}✓${NC} No recent errors detected\n"
else
    printf "${YELLOW}⚠${NC} Found $ERROR_COUNT error lines in logs\n"
    echo ""
    echo "Recent errors:"
    docker compose logs --tail=100 2>/dev/null | grep -i "error" | head -5
fi

echo ""

# ===== SUMMARY =====
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║ HEALTH CHECK COMPLETE                                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Documentation:"
echo "  • Setup: ./README.md"
echo "  • Security: ./SECURITY.md"
echo "  • Deployment: ./DEPLOYMENT.md"
echo ""
echo "Useful commands:"
echo "  • View all logs:     docker compose logs -f"
echo "  • View one service:  docker compose logs -f <service>"
echo "  • SSH into service:  docker compose exec <service> bash"
echo "  • Restart service:   docker compose restart <service>"
echo ""
