#!/usr/bin/env bash
set -euo pipefail

# Colors
CYAN='\033[0;36m'
NC='\033[0m'

# Variables
SECRETS_DIR="./secrets"
SECRETS_FILE="${SECRETS_DIR}/db.env"
LENGTH=32

# Ensure the script is running from the Wavelog project root directory
if [[ ! -f "docker-compose.yaml" ]]; then
    echo "ERROR: This script must be run from the Wavelog project root, not from the scripts directory." >&2
    echo -e "Try running as: ${CYAN}sudo ./scripts/$(basename ${0})${NC}" >&2
    exit 1
fi

# Ensure the script is being run as root
if [[ "$EUID" -ne 0 ]]; then
    echo "ERROR: This script must be run as root." >&2
    echo -e "Try running as: ${CYAN}sudo ./scripts/$(basename ${0})${NC}" >&2
    exit 1
fi

# Ensure we are not about to overwrite existing secrets
if [[ -e "$SECRETS_FILE" ]]; then
    echo "ERROR: Secrets file already exists. Aborting to prevent overwriting secrets." >&2
    exit 1
fi

# Generate database password
DB_PASSWORD="$(head -c 1000 /dev/urandom | tr -dc 'A-Za-z0-9' | head -c "$LENGTH")"

# Create secrets directory
mkdir -p "$SECRETS_DIR"

# Write secrets file
tmpfile="$(mktemp)"
chmod 600 "$tmpfile"

cat > "$tmpfile" <<EOF
MARIADB_PASSWORD=${DB_PASSWORD}
EOF

mv "$tmpfile" "$SECRETS_FILE"

# Ensure Docker daemon is started and enabled on boot
if command -v systemctl >/dev/null 2>&1; then
  systemctl enable docker 2>/dev/null
  systemctl start docker
fi

# Start the application
docker compose up -d

# Report success
echo -e "Successfully configured Wavelog environment. Visit ${CYAN}http://localhost:8086${NC} in your browser to continue setup. Once that is complete, proceed to Step 2."
echo -e "Database credentials:"
echo -e "Hostname: ${CYAN}wavelog-db${NC}"
echo -e "Database Name: ${CYAN}wavelog${NC}"
echo -e "Username: ${CYAN}wavelog${NC}"
echo -e "Password: ${CYAN}${DB_PASSWORD}${NC}"
echo -e "The password is stored in ${CYAN}./secrets/db.env${NC}"

