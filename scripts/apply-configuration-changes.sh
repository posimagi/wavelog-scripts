#!/usr/bin/env bash
set -euo pipefail

# Colors
CYAN='\033[0;36m'
NC='\033[0m'

# Ensure the script is being run as root
if [[ "$EUID" -ne 0 ]]; then
    echo "ERROR: This script must be run as root." >&2
    echo -e "Try running as: ${CYAN}sudo ./scripts/$(basename ${0})${NC}" >&2
    exit 1
fi

