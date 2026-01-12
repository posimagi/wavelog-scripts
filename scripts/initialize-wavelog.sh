#!/usr/bin/env bash
set -euo pipefail

# Variables
SERVICE_NAME="wavelog-main"
APP_PATH="/var/www/html/application/config/config.php"
VAR_PATH="/var/www/html/application/config/wavelog.php"
APP_DEST="./config/config.php"
VAR_DEST="./config/wavelog.php"
LENGTH=32
SECRETS_DIR="./secrets"
SECRETS_FILE="${SECRETS_DIR}/db.env"

# Ensure Docker daemon is enabled on boot
if command -v systemctl >/dev/null 2>&1; then
  sudo systemctl enable docker
  sudo systemctl start docker
fi

# Generate database password
DB_PASSWORD="$(tr -dc 'A-Za-z0-9!@#$%^&*()-_=+[]{}' < /dev/urandom | head -c "$LENGTH")"

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
docker cp "${CONTAINER_ID}:${APP_PATH}" "${APP_DEST}"
echo "Copied ${APP_PATH} to ${APP_DEST}"

docker cp "${CONTAINER_ID}:${VAR_PATH}" "${VAR_DEST}"
echo "Copied ${VAR_PATH} to ${VAR_DEST}"

