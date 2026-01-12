#!/usr/bin/env bash
set -euo pipefail

# Ensure the script is running as root
if [[ "$EUID" -ne 0 ]]; then
    echo "ERROR: This script must be run as root." >&2
    echo "Try running with sudo: sudo $0" >&2
    exit 1
fi

# Variables
IMAGE_NAME="ghcr.io/wavelog/wavelog:latest"
SERVICE_NAME="wavelog-main"
CONFIG_PATH="/var/www/html/application/config"
CONFIG_DEST="./config"
APP_SAMPLE="config.sample.php"
APP_CONFIG="config.php"
VAR_CONFIG="wavelog.php"
LENGTH=32
SECRETS_DIR="./secrets"
SECRETS_FILE="${SECRETS_DIR}/db.env"

if [[ -e "$SECRETS_FILE" ]]; then
    echo "ERROR: Secrets file already exists. Aborting to prevent overwriting secrets." >&2
    exit 1
fi

# Ensure Docker daemon is enabled on boot
if command -v systemctl >/dev/null 2>&1; then
  systemctl enable docker
  systemctl start docker
fi

mkdir -p "${CONFIG_DEST}"

# Generate database password
DB_PASSWORD="$(head -c 1000 /dev/urandom | tr -dc 'A-Za-z0-9!@#$%^&*' | head -c "$LENGTH")"

# Create secrets directory
mkdir -p "$SECRETS_DIR"

# Write secrets file
tmpfile="$(mktemp)"
chmod 600 "$tmpfile"

cat > "$tmpfile" <<EOF
MARIADB_RANDOM_ROOT_PASSWORD=yes
MARIADB_DATABASE=wavelog
MARIADB_USER=wavelog
MARIADB_PASSWORD=${DB_PASSWORD}
EOF

mv "$tmpfile" "$SECRETS_FILE"

# Create a temporary container to extract default config files
TEMP_CONTAINER=$(docker create "$IMAGE_NAME")

docker cp "${TEMP_CONTAINER}:/var/www/html/application/config/config.sample.php" "$CONFIG_DEST/config.php"
docker cp "${TEMP_CONTAINER}:/var/www/html/application/config/wavelog.php" "$CONFIG_DEST/wavelog.php"

# Start the service
docker compose up -d "${SERVICE_NAME}"

