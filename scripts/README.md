# NixOS 1Password SSH Integration

This directory contains scripts and configurations for integrating 1Password SSH agent with NixOS systems using the opnix module. These tools enable secure, key-less SSH connections between a NixOS-WSL environment and a bare metal NixOS workstation.

## Setup Process Overview

1. **Configure Home Manager** with the opnix module to integrate with 1Password SSH agent
2. **Create an opnix token & security group** for authentication with 1Password
3. **Deploy the configuration** to the WSL environment
4. **Test SSH connectivity** to the remote NixOS host
5. **Fix any issues** on the remote host if needed

## Requirements

- NixOS-WSL environment (PC)
- NixOS bare metal workstation (WS)
- 1Password desktop application running on Windows host with SSH agent enabled
- Home Manager installed and configured on both systems

## Scripts

### 0. `opnix-setup.sh` (Recommended)

All-in-one setup script for 1Password integration. This is the recommended way to set up the integration as it handles all the steps in the correct order.

```bash
# Run as root
sudo ./opnix-setup.sh <1password-token> --rebuild
```

This script will:

- Create the 1Password token file
- Set up the security group
- Configure proper permissions
- Optionally rebuild the NixOS configuration

Run with `--help` for more options:

```bash
sudo ./opnix-setup.sh --help
```

### 1. `setup-opnix-token.sh` (Manual Alternative)

Sets up the opnix token file for 1Password authentication.

```bash
# Run as root
sudo ./setup-opnix-token.sh <1password-token>
```

You can generate a token in the 1Password desktop app:

1. Go to Settings > Developer
2. Click 'Create New Token'
3. Give it a name like 'NixOS opnix integration'
4. Copy the token and provide it to the script

### 2. `setup-opnix-group.sh` (Manual Alternative)

Creates a dedicated group for secure token access (recommended).

```bash
# Run as root after setting up the token
sudo ./setup-opnix-group.sh
```

This script will:

- Create the `onepassword-secrets` group
- Add the user to this group
- Set proper permissions on the token file
- Print configuration guidance

### 3. `test-ssh-connection.sh`

Tests SSH connection to the remote host using 1Password SSH agent.

```bash
./test-ssh-connection.sh
```

This script will:

- Verify that 1Password SSH agent socket exists
- Check available SSH keys in the agent
- Test SSH connection to the remote host with verbose output
- Display useful troubleshooting information if the connection fails

### 4. `temp_opnix_fix.sh`

Fixes SSH server configuration on the remote NixOS host.

```bash
# Send to remote host and execute there
ssh ryzengrind@192.168.1.3 'bash -s' < ./temp_opnix_fix.sh
```

This script will:

- Check for and configure SSH public keys
- Set proper permissions for SSH files
- Verify SSH server configuration
- Restart SSH server if needed

## Configuration Steps

### 1. Add opnix to Flake Inputs

```nix
# In flake.nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  # ... other inputs
  opnix.url = "github:brizzbuzz/opnix";
};
```

### 2. Configure System-Level opnix (Optional but Recommended)

```nix
# In configuration.nix
{ config, pkgs, ... }:

{
  # ... other configuration

  services.onepassword-secrets = {
    enable = true;
    users = [ "ryzengrind" ];  # Users that need secret access
    tokenFile = "/etc/opnix-token";  # Default location
    outputDir = "/var/lib/opnix/secrets";  # Optional, this is the default
  };

  # Create the onepassword-secrets group
  users.groups.onepassword-secrets = {};
}
```

### 3. Configure Home Manager

```nix
# In home-ryzengrind.nix
{ config, pkgs, flakeInputs, ... }:
{
  imports = [
    flakeInputs.opnix.homeManagerModules.default
  ];

  # 1Password integration with correct module structure
  programs.onepassword-secrets = {
    enable = true;
    # Configure at least one secret to satisfy the module requirement
    secrets = [
      {
        path = ".ssh/id_ed25519";
        reference = "op://Private/SSH Key/private key";
      }
    ];
  };

  # Configure SSH client properly to work with 1Password SSH agent
  programs.ssh = {
    enable = true;

    # Basic SSH client configuration
    controlMaster = "auto";
    controlPersist = "10m";

    # Configure 1Password SSH agent integration
    extraConfig = ''
      Host *
          IdentityAgent ~/.1password/agent.sock
    '';

    # Ensure we match the remote host
    matchBlocks = {
      "nix-ws" = {
        hostname = "192.168.1.3";
        user = "ryzengrind";
        forwardAgent = true;
      };
    };
  };
}
```

### 4. Store SSH Keys in 1Password

- Add your SSH key to 1Password
- Configure the key for SSH agent in 1Password settings
- Ensure "Use the SSH agent" is enabled in 1Password settings

### 5. Deploy Configuration

```bash
# Create opnix token file (must be run as root)
sudo ./setup-opnix-token.sh <1password-token>

# Set up proper group and permissions (recommended)
sudo ./setup-opnix-group.sh

# Rebuild NixOS configuration
cd /home/ryzengrind/nix-pc && sudo nixos-rebuild switch --flake .#nix-pc
```

### 6. Test SSH Connection

```bash
./test-ssh-connection.sh
```

If the connection fails, try the temporary fix script:

```bash
ssh ryzengrind@192.168.1.3 'bash -s' < ./temp_opnix_fix.sh
```

## Common Issues and Troubleshooting

### 1. Token File Permissions

If you see errors like `Error: Cannot read system token at /etc/opnix-token`:

- Ensure the token file exists
- Run the `setup-opnix-group.sh` script to set up proper permissions
- Make sure your user is in the `onepassword-secrets` group
- You may need to log out and log back in for group changes to take effect

### 2. SSH Agent Socket Issues

If the 1Password SSH agent socket is not found:

- Check that 1Password SSH agent is running on Windows host
- Verify the Windows 1Password agent is properly integrated with WSL
- The socket path should be `~/.1password/agent.sock`

### 3. Authentication Failures

If you see "Permission denied" errors:

- Run `ssh-add -l` to check if the SSH agent recognizes any keys
- Use `ssh -v nix-ws` for verbose connection debugging output
- Check authorized_keys on the remote host has proper permissions
- Ensure the key in 1Password is correctly marked for SSH agent use

## Architecture

OPNix (opnix) is a secure integration tool between 1Password and NixOS for managing secrets during system builds and home directory setup. This integration leverages:

- **Service Account Token**: Allows authenticated access to 1Password vaults
- **Secret References**: Structured paths to specific items in 1Password
- **Group-based Access Control**: The `onepassword-secrets` group manages token access
- **SSH Agent Integration**: 1Password's SSH agent securely manages SSH keys
- **Socket Forwarding**: Windows 1Password agent socket is accessible from WSL

Created: May 17, 2025
Author: ryzengrind
Version: 1.1
