#!/usr/bin/env bash
set -euo pipefail

# Variables
SECRETS_DIR="./secrets"
SECRETS_FILE="${SECRETS_DIR}/db.env"
LENGTH=32

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

# Ensure we are not about to overwrite existing secrets
if [[ -e "$SECRETS_FILE" ]]; then
    echo "ERROR: Secrets file already exists. Aborting to prevent overwriting secrets." >&2
    exit 1
fi

# Generate database password
DB_PASSWORD="$(head -c 1000 /dev/urandom | tr -dc 'A-Za-z0-9!@#$%^&*' | head -c "$LENGTH")"

# Create secrets directory
mkdir -p "$SECRETS_DIR"

# Write secrets file
tmpfile="$(mktemp)"
chmod 600 "$tmpfile"

cat > "$tmpfile" <<EOF
MARIADB_PASSWORD=${DB_PASSWORD}
EOF

mv "$tmpfile" "$SECRETS_FILE"

