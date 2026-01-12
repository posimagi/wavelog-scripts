#!/usr/bin/env bash
set -euo pipefail

# Colors
CYAN='\033[0;36m'
NC='\033[0m'

# Ensure Docker daemon is started and enabled on boot
if command -v systemctl >/dev/null 2>&1; then
  systemctl enable docker
  systemctl start docker
fi

# Start the application
docker compose up -d

# Direct user to the web UI to continue setup
echo -e "To perform initial setup, visit ${CYAN}http://localhost:8086${NC} in your browser."
echo "After that is complete, proceed to step 3."
