#!/bin/bash
# setup-opnix-token.sh - Create and configure the opnix token file
# This script must be run as root

set -euo pipefail

TOKEN_FILE="/etc/opnix-token"
USER="ryzengrind"

if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root"
  exit 1
fi

if [ $# -eq 0 ]; then
  echo "Usage: $0 <1password-token>"
  echo "You can generate a token in the 1Password desktop app:"
  echo "  1. Go to Settings > Developer"
  echo "  2. Click 'Create New Token'"
  echo "  3. Give it a name like 'NixOS opnix integration'"
  echo "  4. Copy the token and provide it to this script"
  exit 1
fi

TOKEN="$1"

echo "Creating opnix token file at $TOKEN_FILE..."
echo "$TOKEN" > "$TOKEN_FILE"

echo "Setting permissions..."
chmod 640 "$TOKEN_FILE"
chown root:$USER "$TOKEN_FILE"

echo "Token file created and configured with proper permissions."
echo "Now you can run: sudo nixos-rebuild switch --flake /home/$USER/nix-pc#nix-pc"