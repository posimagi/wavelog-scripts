#!/usr/bin/env bash
set -euo pipefail

# Ensure the script is running as root
if [[ "$EUID" -ne 0 ]]; then
    echo "ERROR: This script must be run as root." >&2
    echo "Try running with sudo: sudo $0" >&2
    exit 1
fi


# Variables
SERVICE_NAME="wavelog-main"
CONFIG_PATH="/var/www/html/application/config"
CONFIG_DEST="./config"
APP_CONFIG="config.php"
VAR_CONFIG="wavelog.php"
LENGTH=32
SECRETS_DIR="./secrets"
SECRETS_FILE="${SECRETS_DIR}/db.env"

# Ensure Docker daemon is enabled on boot
if command -v systemctl >/dev/null 2>&1; then
  systemctl enable docker
  systemctl start docker
fi

mkdir -p "${CONFIG_DEST}"

# Generate database password
DB_PASSWORD="$(head -c 100 /dev/urandom | tr -dc 'A-Za-z0-9!@#$%^&*' | head -c "$LENGTH")"

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

# Ensure the service is running
docker compose up -d "${SERVICE_NAME}"

# Get the container ID for the service
CONTAINER_ID=$(docker compose ps -q "${SERVICE_NAME}")

if [[ -z "${CONTAINER_ID}" ]]; then
  echo "Failed to determine container ID for service '${SERVICE_NAME}'"
  exit 1
fi

# Copy the file out of the container
docker cp "${CONTAINER_ID}:${CONFIG_PATH}/${APP_CONFIG}" "${CONFIG_DEST}/${APP_CONFIG}"
echo "Copied ${CONFIG_PATH}/${APP_CONFIG} to ${CONFIG_DEST}/${APP_CONFIG}"

docker cp "${CONTAINER_ID}:${CONFIG_PATH}/${VAR_CONFIG}" "${CONFIG_DEST}/${VAR_CONFIG}"
echo "Copied ${CONFIG_PATH}/${VAR_CONFIG} to ${CONFIG_DEST}/${VAR_CONFIG}"

