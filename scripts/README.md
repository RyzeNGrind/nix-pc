# NixOS 1Password SSH Integration

This directory contains scripts and configuration for integrating 1Password SSH agent with NixOS systems using the opnix module. These tools enable secure, key-less SSH connections between a NixOS-WSL environment and a bare metal NixOS workstation.

## Setup Process Overview

1. **Configure Home Manager** with the opnix module to integrate with 1Password SSH agent
2. **Create opnix token** for authentication with 1Password
3. **Deploy the configuration** to the WSL environment
4. **Test SSH connectivity** to the remote NixOS host
5. **Fix any issues** on the remote host if needed

## Requirements

- NixOS-WSL environment (PC)
- NixOS bare metal workstation (WS)
- 1Password desktop application running on Windows host with SSH agent enabled
- Home Manager installed and configured on both systems

## Scripts

### 1. `setup-opnix-token.sh`

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

### 2. `test-ssh-connection.sh`

Tests SSH connection to the remote host using 1Password SSH agent.

```bash
./test-ssh-connection.sh
```

This script will:
- Verify that 1Password SSH agent socket exists
- Check available SSH keys in the agent
- Test SSH connection to the remote host with verbose output
- Display useful troubleshooting information if the connection fails

### 3. `temp_opnix_fix.sh`

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

### 2. Configure Home Manager

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

### 3. Store SSH Keys in 1Password

- Add your SSH key to 1Password
- Configure the key for SSH agent in 1Password settings
- Ensure "Use the SSH agent" is enabled in 1Password settings

### 4. Deploy Configuration

```bash
# Create opnix token file (must be run as root)
sudo ./setup-opnix-token.sh <1password-token>

# Rebuild NixOS configuration
cd /home/ryzengrind/nix-pc && sudo nixos-rebuild switch --flake .#nix-pc
```

### 5. Test SSH Connection

```bash
./test-ssh-connection.sh
```

If the connection fails, try the temporary fix script:

```bash
ssh ryzengrind@192.168.1.3 'bash -s' < ./temp_opnix_fix.sh
```

### Common Issues:

1. **SSH agent socket not found**:
 
- Check that 1Password SSH agent is running on Windows host
- Verify the Windows 1Password SSH agent is properly integrated with WSL

2. **Permission denied errors**:

- Run `ssh-add -l` to check if the SSH agent recognizes any keys
- Use `ssh -v nix-ws` for verbose connection debugging output
- Check authorized_keys on nix-ws with proper permissions

## Architecture

The integration leverages the following components:

- **opnix**: Home Manager module for 1Password integration
- **1Password SSH Agent**: Manages SSH keys securely in 1Password
- **SSH Configuration**: Directs SSH client to use the 1Password agent
- **WSL Integration**: Forwards Windows 1Password socket to NixOS-WSL

Created: May 17, 2025  
Author: ryzengrind  
Version: 1.0