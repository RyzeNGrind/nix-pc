#!/bin/bash
# opnix-setup.sh - Complete 1Password SSH integration setup for NixOS
# This script must be run as root

set -euo pipefail

# Default paths and values
TOKEN_FILE="/etc/opnix-token"
USER="ryzengrind"
GROUP="onepassword-secrets"
CONFIG_DIR="/home/$USER/nix-pc"

# Function to show help
show_help() {
    echo "Usage: sudo $0 <1password-token> [options]"
    echo ""
    echo "This script performs the complete setup for 1Password SSH integration using opnix:"
    echo "  1. Creates and secures the 1Password token file"
    echo "  2. Sets up a dedicated group for token access"
    echo "  3. Adds the specified user to the group"
    echo "  4. Optionally rebuilds the NixOS configuration"
    echo ""
    echo "Options:"
    echo "  -h, --help               Show this help message"
    echo "  -u, --user USERNAME      Specify user (default: ryzengrind)"
    echo "  -g, --group GROUPNAME    Specify group (default: onepassword-secrets)"
    echo "  -p, --path PATH          Path to token file (default: /etc/opnix-token)"
    echo "  -c, --config DIR         NixOS config directory (default: /home/ryzengrind/nix-pc)"
    echo "  -r, --rebuild            Rebuild NixOS configuration after setup"
    echo ""
    echo "Example:"
    echo "  sudo $0 \"ops_eyJzaWduSW...\" --rebuild"
    echo ""
}

# Check if we're running as root
if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run as root"
  exit 1
fi

# Parse command line arguments
REBUILD=false
TOKEN=""

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -h|--help)
            show_help
            exit 0
            ;;
        -u|--user)
            USER="$2"
            shift 2
            ;;
        -g|--group)
            GROUP="$2"
            shift 2
            ;;
        -p|--path)
            TOKEN_FILE="$2"
            shift 2
            ;;
        -c|--config)
            CONFIG_DIR="$2"
            shift 2
            ;;
        -r|--rebuild)
            REBUILD=true
            shift
            ;;
        *)
            if [ -z "$TOKEN" ]; then
                TOKEN="$1"
                shift
            else
                echo "Error: Unknown option $1"
                show_help
                exit 1
            fi
            ;;
    esac
done

# Check if token is provided
if [ -z "$TOKEN" ]; then
    echo "Error: 1Password token is required"
    show_help
    exit 1
fi

# Verify the user exists
if ! id -u "$USER" &>/dev/null; then
    echo "Error: User $USER does not exist"
    exit 1
fi

echo "=== 1Password NixOS Integration Setup ==="
echo "User: $USER"
echo "Group: $GROUP"
echo "Token file: $TOKEN_FILE"
echo "NixOS config: $CONFIG_DIR"
echo ""

# Step 1: Create token file
echo "Step 1: Creating opnix token file..."
echo "$TOKEN" > "$TOKEN_FILE"
chmod 600 "$TOKEN_FILE"
echo "✓ Token file created"

# Step 2: Set up group
echo ""
echo "Step 2: Setting up security group..."

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

# Step 3: Set proper permissions on token file
echo ""
echo "Step 3: Setting file permissions..."
chown root:"$GROUP" "$TOKEN_FILE"
chmod 640 "$TOKEN_FILE"
echo "✓ File permissions updated"

# Step 4: Optionally rebuild NixOS
if [ "$REBUILD" = true ]; then
    echo ""
    echo "Step 4: Rebuilding NixOS configuration..."
    if [ -d "$CONFIG_DIR" ]; then
        cd "$CONFIG_DIR"
        nixos-rebuild switch --flake ".#nix-pc"
        REBUILD_STATUS=$?
        if [ $REBUILD_STATUS -eq 0 ]; then
            echo "✓ NixOS configuration rebuilt successfully"
        else
            echo "❌ NixOS rebuild failed with exit code $REBUILD_STATUS"
            echo "Please check the error messages above"
        fi
    else
        echo "❌ NixOS configuration directory not found: $CONFIG_DIR"
        echo "Skipping rebuild step"
    fi
else
    echo ""
    echo "Step 4: Skipping NixOS rebuild (use --rebuild to enable)"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. If you didn't use --rebuild, rebuild your NixOS configuration:"
echo "     cd $CONFIG_DIR && sudo nixos-rebuild switch --flake .#nix-pc"
echo "  2. Log out and log back in for group changes to take effect"
echo "  3. Test the SSH connection with ./test-ssh-connection.sh"
echo ""
echo "NOTE: You may need to restart your session for group changes to take effect."