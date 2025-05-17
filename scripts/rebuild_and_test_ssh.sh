#!/usr/bin/env bash
set -euo pipefail

# Colors for better readability
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Starting NixOS Rebuild Process ===${NC}"

# Step 1: Rebuild the NixOS configuration
echo -e "${YELLOW}Rebuilding NixOS configuration...${NC}"
sudo nixos-rebuild switch --flake '/home/ryzengrind/nix-cfg#nix-pc'

if [ $? -ne 0 ]; then
  echo -e "${RED}Error: NixOS rebuild failed. Exiting.${NC}"
  exit 1
fi

echo -e "${GREEN}NixOS configuration rebuilt successfully.${NC}"

# Step 2: Verify the SSH agent is running
echo -e "${YELLOW}Checking if SSH agent is running...${NC}"
if pgrep -f "ssh-agent" > /dev/null; then
  echo -e "${GREEN}SSH agent is running.${NC}"
else
  echo -e "${RED}Warning: SSH agent is not running.${NC}"
  echo -e "${YELLOW}Starting SSH agent...${NC}"
  eval $(ssh-agent)
fi

# Display SSH agent environment variables
echo -e "${YELLOW}SSH Agent Environment:${NC}"
env | grep SSH

# Step 3: Check if 1Password SSH agent socket exists
echo -e "${YELLOW}Checking for 1Password SSH agent socket...${NC}"
if [ -S "$HOME/.1password/agent.sock" ]; then
  echo -e "${GREEN}1Password SSH agent socket exists.${NC}"
else
  echo -e "${RED}Warning: 1Password SSH agent socket does not exist.${NC}"
  echo -e "${YELLOW}Please ensure 1Password is running on the Windows host with SSH agent enabled.${NC}"
fi

# Step 4: Test SSH connection to nix-ws
echo -e "${YELLOW}Testing SSH connection to nix-ws (192.168.1.3)...${NC}"
echo -e "${YELLOW}Attempting to connect and run 'hostname' command...${NC}"

# First try with verbose output in case of issues
ssh -v -o ConnectTimeout=5 nix-ws hostname 2>&1 | tee /tmp/ssh_test_verbose.log

if [ ${PIPESTATUS[0]} -eq 0 ]; then
  echo -e "${GREEN}SSH connection successful!${NC}"
  
  # Test additional commands
  echo -e "${YELLOW}Testing additional commands...${NC}"
  echo -e "${YELLOW}Current user on remote system:${NC}"
  ssh nix-ws whoami
  
  echo -e "${YELLOW}Remote system details:${NC}"
  ssh nix-ws "uname -a && cat /etc/os-release | grep PRETTY_NAME"
  
  echo -e "${GREEN}All tests completed successfully.${NC}"
else
  echo -e "${RED}SSH connection failed.${NC}"
  echo -e "${YELLOW}Verbose output saved to /tmp/ssh_test_verbose.log${NC}"
  echo -e "${YELLOW}Check the following:${NC}"
  echo -e "  1. 1Password is running on the Windows host with SSH agent enabled"
  echo -e "  2. The SSH key in 1Password is correctly set up for the remote host"
  echo -e "  3. Network connectivity to 192.168.1.3 is available"
  echo -e "  4. The SSH server on nix-ws is running and accessible"
fi

# Display SSH agent identities
echo -e "${YELLOW}Checking for SSH identities...${NC}"
ssh-add -l || echo -e "${RED}No identities found or ssh-agent not running.${NC}"

echo -e "${YELLOW}=== Test completed ===${NC}"