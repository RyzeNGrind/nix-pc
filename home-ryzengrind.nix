{
  config,
  pkgs,
  lib,
  flakeInputs,
  ...
}:
# flakeInputs is available from extraSpecialArgs
{
  # Import opnix module for 1Password SSH agent integration
  imports = [
    flakeInputs.opnix.homeManagerModules.default
  ];

  home.username = "ryzengrind";
  home.homeDirectory = "/home/ryzengrind";
  home.stateVersion = "24.05"; # Latest supported by current Home Manager

  # You can add a simple package to test if Home Manager is working at all
  # home.packages = [ pkgs.hello ];

  # Enable opnix for 1Password SSH agent integration - correctly defined using onepassword-secrets
  programs.onepassword-ssh = {
    enable = true;
    enableAgent = true;
    enableSSHKeyGeneration = false;
  };

  # Configure SSH properly to work with 1Password SSH agent
  programs.ssh = {
    enable = true;
    
    # Basic SSH client configuration
    controlMaster = "auto";
    controlPersist = "10m";
    
    # Ensure we match the remote host
    matchBlocks = {
      "nix-ws" = {
        hostname = "192.168.1.3";
        user = "ryzengrind";
        identityFile = "~/.ssh/id_ed25519"; # This is symbolic, actual key managed by 1Password
        identitiesOnly = true;
        forwardAgent = true;
      };
    };
  };

  # Disable the release check warning
  home.enableNixpkgsReleaseCheck = false;

  # Allow Home Manager to manage itself
  programs.home-manager.enable = true;
}
