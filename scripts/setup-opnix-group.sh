#!/bin/bash
# setup-opnix-group.sh - Create and configure the onepassword-secrets group 
# This script must be run as root

set -euo pipefail

TOKEN_FILE="/etc/opnix-token"
USER="ryzengrind"
GROUP="onepassword-secrets"

if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root"
  exit 1
fi

echo "=== Setting up onepassword-secrets group for opnix ==="

# Check if group already exists
if ! getent group "$GROUP" >/dev/null 2>&1; then
  echo "Creating group $GROUP..."
  groupadd "$GROUP"
  echo "✓ Group created"
else
  echo "✓ Group $GROUP already exists"
fi

# Add user to group if not already a member
if ! groups "$USER" | grep -q "\b$GROUP\b"; then
  echo "Adding user $USER to group $GROUP..."
  usermod -aG "$GROUP" "$USER"
  echo "✓ User added to group"
else
  echo "✓ User $USER is already in group $GROUP"
fi

# Set proper permissions on token file if it exists
if [ -f "$TOKEN_FILE" ]; then
  echo "Setting permissions on $TOKEN_FILE..."
  chown root:"$GROUP" "$TOKEN_FILE"
  chmod 640 "$TOKEN_FILE"
  echo "✓ File permissions updated"
else
  echo "⚠️ Token file not found at $TOKEN_FILE"
  echo "Please run setup-opnix-token.sh first to create the token file"
fi

echo ""
echo "✅ Group setup completed"
echo ""
echo "To use the token file with opnix, make sure to:"
echo "  1. Ensure opnix is properly configured in your NixOS configuration:"
echo "      services.onepassword-secrets = {"
echo "        enable = true;"
echo "        users = [ \"$USER\" ];"
echo "        tokenFile = \"$TOKEN_FILE\";"
echo "        # ... other options"
echo "      };"
echo "  2. Rebuild your NixOS configuration:"
echo "      sudo nixos-rebuild switch --flake .#nix-pc"
echo ""
echo "You may need to log out and back in for group changes to take effect"