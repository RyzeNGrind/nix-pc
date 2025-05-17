# 1Password SSH Agent Integration for NixOS

This directory contains scripts to configure and test the integration between 1Password SSH agent and NixOS, enabling secure SSH key management and authentication between NixOS systems.

## Overview

The setup enables SSH authentication from the WSL NixOS instance (`nix-pc`) to a bare metal NixOS system (`nix-ws`) using SSH keys managed by 1Password. This provides several benefits:

- **Security**: SSH private keys are safely stored in 1Password vault, never exposed on disk
- **Convenience**: No need to type passwords for SSH connections once configured
- **Reproducibility**: The entire configuration is managed declaratively via NixOS modules

## Prerequisites

1. 1Password desktop application running on the Windows host with SSH agent enabled
2. NixOS WSL (`nix-pc`) with Home Manager and proper opnix integration
3. NixOS bare metal (`nix-ws`) with SSH server running and accessible via network

## Configuration Files

The core of this solution involves:

1. **NixOS configuration**: Enables the proper modules for SSH agent integration
2. **Home Manager configuration**: Configures the 1Password SSH integration on the user level

### Key Configuration Components

In the Home Manager configuration (`home-ryzengrind.nix`), the following modules are configured:

```nix
# 1Password SSH integration
programs.onepassword-ssh = {
  enable = true;
  enableAgent = true;
  enableSSHKeyGeneration = false;
};

# Configure SSH client
programs.ssh = {
  enable = true;
  
  # Basic SSH client configuration
  controlMaster = "auto";
  controlPersist = "10m";
  
  # Remote host configuration
  matchBlocks = {
    "nix-ws" = {
      hostname = "192.168.1.3";
      user = "ryzengrind";
      identityFile = "~/.ssh/id_ed25519"; # Symbolic reference, actual key in 1Password
      identitiesOnly = true;
      forwardAgent = true;
    };
  };
};
```

## Scripts

This directory contains two scripts to help manage and test the SSH connection:

### 1. `rebuild_and_test_ssh.sh`

Tests the SSH connection configuration by:
- Rebuilding the NixOS configuration
- Verifying SSH agent operation
- Testing connectivity to the remote NixOS host
- Performing diagnostic checks

**Usage:**
```bash
./rebuild_and_test_ssh.sh
```

### 2. `temp_opnix_fix.sh`

A utility script to run on the remote server (`nix-ws`) to troubleshoot SSH connection issues:
- Ensures authorized_keys file exists with correct permissions
- Checks if SSH server is running
- Validates SSH server configuration
- Diagnoses common SSH-related issues

**Usage:**
```bash
# Run locally on nix-ws
./temp_opnix_fix.sh

# Or run remotely via SSH once basic connectivity works
ssh ryzengrind@192.168.1.3 'bash -s' < ./temp_opnix_fix.sh
```

## Using the 1Password SSH Integration

1. **Store SSH Keys in 1Password**:
   - Add your SSH key to 1Password
   - Configure the key for SSH agent in 1Password settings
   - Ensure "Use the SSH agent" is enabled in 1Password settings

2. **Connect to Remote Server**:
   - With the integration enabled, simply use: `ssh nix-ws`
   - 1Password will provide the authentication via its SSH agent

## Troubleshooting

### Common Issues:

1. **SSH agent socket not found**:
   - Check that 1Password SSH agent is running on Windows host
   - Verify the Windows 1Password SSH agent is properly integrated with WSL

2. **Permission denied errors**:
   - Run `ssh-add -l` to check if the SSH agent recognizes any keys
   - Use `ssh -v nix-ws` for verbose connection debugging output
   - Check authorized_keys on nix-ws with proper permissions

3. **Socket path issues**:
   - The 1Password SSH agent socket should be linked to `~/.1password/agent.sock`
   - Verify `SSH_AUTH_SOCK` environment variable is properly set

### Testing SSH Agent

```bash
# Check SSH agent environment variables
env | grep SSH

# List loaded identities
ssh-add -l

# Test connection with verbose output
ssh -v nix-ws
```

## Technical Details

The integration leverages the following components:

1. **opnix Flake Input**: Provides NixOS and Home Manager modules for 1Password integration
2. **Home Manager SSH Client**: Configured to use 1Password SSH agent
3. **1Password SSH Agent Socket**: Integrated into WSL to provide authentication services
4. **SSH Agent Forwarding**: Enabled for multi-hop SSH scenarios

---

Created: May 17, 2025  
Author: ryzengrind  
Version: 1.0