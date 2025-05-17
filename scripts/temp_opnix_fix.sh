#!/bin/bash
# temp_opnix_fix.sh - Fix SSH server configuration on the remote NixOS host
# This script is meant to be sent to the remote host and executed there
# Usage: ssh ryzengrind@192.168.1.3 'bash -s' < ./temp_opnix_fix.sh

set -euo pipefail

SSH_KEY_PATH="/home/ryzengrind/.ssh/id_ed25519.pub"
AUTH_KEYS_PATH="/home/ryzengrind/.ssh/authorized_keys"

echo "=== Temporary SSH Server Fix for 1Password Integration ==="
echo "Running as: $(whoami) on $(hostname)"
echo ""

# Check if we can find the SSH public key
if [ -f "$SSH_KEY_PATH" ]; then
    echo "✓ Found SSH public key: $SSH_KEY_PATH"
    echo "Key content:"
    cat "$SSH_KEY_PATH"
    echo ""
else
    echo "❌ SSH public key not found at $SSH_KEY_PATH"
    echo "Checking current 1Password-managed keys in authorized_keys:"
    if [ -f "$AUTH_KEYS_PATH" ]; then
        grep -i "1password" "$AUTH_KEYS_PATH" || echo "No 1Password keys found in authorized_keys"
    else
        echo "authorized_keys file not found. Creating a new one."
        mkdir -p $(dirname "$AUTH_KEYS_PATH")
        touch "$AUTH_KEYS_PATH"
    fi
    
    echo ""
    echo "Waiting for public key input. Please paste your public key below and press Enter, then Ctrl+D:"
    read PUBLIC_KEY
    
    if [ -n "$PUBLIC_KEY" ]; then
        echo "$PUBLIC_KEY" >> "$AUTH_KEYS_PATH"
        echo "✓ Added public key to authorized_keys"
    else
        echo "❌ No public key provided. Skipping."
    fi
fi

# Ensure authorized_keys has correct permissions
echo "Setting correct permissions for SSH files..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh
touch "$AUTH_KEYS_PATH"
chmod 600 "$AUTH_KEYS_PATH"
echo "✓ Permissions set correctly"

# Check if authorized_keys contains the key
if [ -f "$SSH_KEY_PATH" ] && [ -f "$AUTH_KEYS_PATH" ]; then
    if grep -q "$(cat $SSH_KEY_PATH)" "$AUTH_KEYS_PATH"; then
        echo "✓ SSH key is already in authorized_keys"
    else
        echo "Adding SSH key to authorized_keys..."
        cat "$SSH_KEY_PATH" >> "$AUTH_KEYS_PATH"
        echo "✓ SSH key added to authorized_keys"
    fi
fi

# Check SSH server configuration
echo ""
echo "Checking SSH server configuration..."
if command -v sudo &> /dev/null && sudo -n true 2>/dev/null; then
    SSHD_CONFIG="/etc/ssh/sshd_config"
    
    # Check for PubkeyAuthentication setting
    if sudo grep -q "^PubkeyAuthentication" $SSHD_CONFIG; then
        echo "✓ PubkeyAuthentication is explicitly set"
    else
        echo "⚠️ PubkeyAuthentication not explicitly set (defaults to yes)"
    fi
    
    # Check for AuthorizedKeysFile setting
    if sudo grep -q "^AuthorizedKeysFile" $SSHD_CONFIG; then
        echo "✓ AuthorizedKeysFile is explicitly set"
        echo "  Setting: $(sudo grep "^AuthorizedKeysFile" $SSHD_CONFIG)"
    else
        echo "⚠️ AuthorizedKeysFile not explicitly set (defaults to ~/.ssh/authorized_keys)"
    fi
    
    # Check if SSH server needs restart
    echo ""
    echo "Checking SSH server status..."
    if sudo systemctl is-active sshd > /dev/null; then
        echo "✓ SSH server is running"
    else
        echo "❌ SSH server is not running. Attempting to start..."
        sudo systemctl start sshd
    fi
    
    # Optionally restart SSH server if needed
    echo ""
    read -p "Would you like to restart the SSH server to apply any changes? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Restarting SSH server..."
        sudo systemctl restart sshd
        echo "✓ SSH server restarted"
    fi
else
    echo "⚠️ Cannot check SSH server configuration (sudo access required)"
fi

echo ""
echo "✅ SSH configuration check completed"
echo "If you still have connection issues, check SSH server logs with:"
echo "  sudo journalctl -u sshd"
echo ""
echo "Test the connection with verbose output:"
echo "  ssh -v ryzengrind@$(hostname -I | awk '{print $1}')"