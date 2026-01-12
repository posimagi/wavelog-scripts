#!/usr/bin/env bash
set -euo pipefail

# Variables
IMAGE_NAME="ghcr.io/wavelog/wavelog:latest"
CONFIG_PATH="/var/www/html/application/config"
CONFIG_DEST="./config"
COMPOSE_SRC="post-setup/docker-compose.yaml"
COMPOSE_DST="./docker-compose.yaml"

# Ensure the script is running from the Wavelog project root directory
if [[ ! -f "docker-compose.yaml" ]]; then
    echo "ERROR: This script must be run from the Wavelog project root, not from the scripts directory." >&2
    echo "Try running as: sudo ./scripts/$(basename ${0})" >&2
    exit 1
fi

# Ensure the script is being run as root
if [[ "$EUID" -ne 0 ]]; then
    echo "ERROR: This script must be run as root." >&2
    echo "Try running as: sudo ./scripts/$(basename ${0})" >&2
    exit 1
fi

# Ensure we are not about to overwrite existing configs
if [[ -d "$CONFIG_DEST" && "$(ls -A "$CONFIG_DEST")" ]]; then
    echo "ERROR: '$CONFIG_DEST' already exists and is not empty. Aborting to prevent overwriting configuration." >&2
    exit 1
fi

# Create the local config directory
mkdir -p "${CONFIG_DEST}"

# Create a temporary container to extract default config files
TEMP_CONTAINER=$(docker create "$IMAGE_NAME")

# Extract the files
docker cp "${TEMP_CONTAINER}:/var/www/html/application/config/config.sample.php" "${CONFIG_DEST}/config.php"
docker cp "${TEMP_CONTAINER}:/var/www/html/application/config/wavelog.php" "${CONFIG_DEST}/wavelog.php"

# Set correct permissions
chmod 0644 "${CONFIG_DEST}/config.php" 
chmod 0644 "${CONFIG_DEST}/wavelog.php"

# Remove the temporary container
docker rm "$TEMP_CONTAINER"

# Ensure the post-setup config exists
if [[ ! -f "$COMPOSE_SRC" ]]; then
    echo "ERROR: Post-setup docker compose file '$SRC' does not exist." >&2
    exit 1
fi

# Move the file
mv "$SRC" "$DEST"

