#!/bin/bash
# test-ssh-connection.sh - Test SSH connection to nix-ws using 1Password SSH agent
# Run this script after configuring everything

set -euo pipefail

REMOTE_HOST="nix-ws"
REMOTE_IP="192.168.1.3"
REMOTE_USER="ryzengrind"
SOCKET_PATH="$HOME/.1password/agent.sock"

echo "=== Testing 1Password SSH Integration ==="

# Check if 1Password SSH agent socket exists
if [ ! -S "$SOCKET_PATH" ]; then
  echo "ERROR: 1Password SSH agent socket not found at $SOCKET_PATH"
  echo "Possible solutions:"
  echo "  1. Make sure 1Password is running on your Windows host"
  echo "  2. Ensure SSH agent integration is enabled in 1Password settings"
  echo "  3. Check if the socket path is correct in your configuration"
  exit 1
fi

echo "✓ 1Password SSH agent socket found"

# Check what keys the SSH agent sees
echo -e "\nChecking available SSH keys in agent:"
SSH_AUTH_SOCK="$SOCKET_PATH" ssh-add -l
if [ $? -ne 0 ]; then
  echo "ERROR: No keys found in the SSH agent"
  echo "Possible solutions:"
  echo "  1. Add SSH keys to 1Password and mark them for SSH agent use"
  echo "  2. Restart 1Password to refresh the agent"
  exit 1
fi

echo -e "\nTesting SSH connection to $REMOTE_HOST ($REMOTE_IP)..."
echo "This will use verbose output to help diagnose any issues:"
echo -e "--------------------------------------------------------\n"

# Try to connect with verbose output
SSH_AUTH_SOCK="$SOCKET_PATH" ssh -v $REMOTE_USER@$REMOTE_IP "echo 'Connection successful! Host: \$(hostname)'"
EXIT_CODE=$?

echo -e "\n--------------------------------------------------------"

if [ $EXIT_CODE -eq 0 ]; then
  echo -e "\n✓ SSH connection successful using 1Password SSH agent!"
else
  echo -e "\n❌ SSH connection failed (exit code: $EXIT_CODE)"
  echo "Troubleshooting tips:"
  echo "  1. Ensure the remote host is reachable (ping $REMOTE_IP)"
  echo "  2. Verify your public key is in ~/.ssh/authorized_keys on the remote host"
  echo "  3. Check remote SSH server logs: sudo journalctl -u sshd"
  echo "  4. Try the opnix temp fix script: ./temp_opnix_fix.sh"
fi

exit $EXIT_CODE