{
  config,
  pkgs,
  lib,
  flakeInputs,
  ...
}:
# flakeInputs is available from extraSpecialArgs
{
  # Home Manager configuration
  imports = [
    flakeInputs.opnix.homeManagerModules.default  # Import the opnix Home Manager module
  ];

  home.username = "ryzengrind";
  home.homeDirectory = "/home/ryzengrind";
  home.stateVersion = "24.05"; # Latest supported by current Home Manager

  # You can add a simple package to test if Home Manager is working at all
  # home.packages = [ pkgs.hello ];

  # We'll install 1Password and tools required for SSH agent bridge
  home.packages = with pkgs; [
    _1password-cli
    _1password-gui-beta
    socat
  ];

  # 1Password integration with correct module structure
  programs.onepassword-secrets = {
    enable = true;
    # Configure at least one secret to satisfy the module requirement
    secrets = [
      {
        path = ".ssh/id_ed25519";
        reference = "op://yttl77unixirazurjzbjjqpfoy/mlqzzezynzl2pfvfte4vdp7sn4/private_key";
      }
    ];
  };
  
  # 1Password handles SSH agent functionality, no separate ssh-agent needed
  
  # Enable the 1Password SSH agent bridge service
  systemd.user.services."1password-ssh-agent-bridge" = {
    Unit = {
      Description = "1Password SSH Agent Bridge for WSL";
      Documentation = "https://nixos.wiki/wiki/1Password";
      After = "network.target";
      # Restart when WSL resumes from sleep
      PartOf = "graphical-session.target";
    };
    Service = {
      Type = "simple";
      ExecStart = "${config.home.homeDirectory}/nix-cfg/scripts/setup-1password-ssh-bridge.sh";
      Restart = "always";
      RestartSec = 5;
      # Load environment from profile if it exists
      Environment = "PATH=${config.home.profileDirectory}/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Configure SSH client properly to work with 1Password SSH agent
  programs.ssh = {
    enable = true;
    
    # Basic SSH client configuration
    controlMaster = "auto";
    controlPersist = "10m";
    
    # Configure 1Password SSH agent integration (standard approach from NixOS Wiki)
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

  # Disable the release check warning
  home.enableNixpkgsReleaseCheck = false;

  # Allow Home Manager to manage itself
  programs.home-manager.enable = true;
}
