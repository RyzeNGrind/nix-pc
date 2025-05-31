# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL
{
  config,
  pkgs,
  #lib,
  inputs,
  ...
}: {
  imports = [
    inputs.nixos-wsl.nixosModules.wsl
    inputs.home-manager.nixosModules.home-manager # Import Home Manager NixOS module
  ];
  # Set up proper nixpkgs configuration with overlays
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
    };
    overlays = [
      # Use the unstable overlay from inputs
      (_final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          inherit (prev) system;
          config.allowUnfree = true;
        };
      })
    ];
  };
  nix.settings = {
    trusted-users = ["root" "@wheel"];
    experimental-features = ["auto-allocate-uids" "ca-derivations" "cgroups" "dynamic-derivations" "fetch-closure" "fetch-tree" "flakes" "git-hashing" "local-overlay-store" "mounted-ssh-store" "no-url-literals" "pipe-operators" "nix-command" "recursive-nix"];
  };
  # Disable documentation options that might cause infinite recursion
  documentation.nixos.includeAllModules = false;
  programs = {
    fish = {
      enable = true;
      interactiveShellInit = ''
        # Manual starship init for fish
        ${pkgs.starship}/bin/starship init fish | source
      '';
    };
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        #  stdenv.cc.cc
        #  zlib
        #  openssl
        #  libunwind
        #  icu
        #  libuuid
      ];
    };
    bash = {
      completion.enable = true;
      interactiveShellInit = ''
        # Initialize starship first
        eval "$(${pkgs.starship}/bin/starship init bash)"
      '';
    };
    starship = {
      enable = true;
      settings = {
        add_newline = true;
        command_timeout = 5000;
        character = {
          error_symbol = "[❯](bold red)";
          success_symbol = "[❯](bold green)";
          vicmd_symbol = "[❮](bold blue)";
        };
        # Add explicit format wrapping
        format = "$all $character";
      };
    };
  };
  environment = {
    shellAliases = {
      # Clear any conflicting aliases
    };
    pathsToLink = ["/share/bash-completion"];
    systemPackages = with pkgs; [
      readline
      bashInteractive # Replace regular bash
      bash-completion # Better completion support
      ncurses # Terminfo database
      wsl-vpnkit
      wget
      jq
      git
      starship
      nix-ld
      binutils
      glibc
      gcc
      python3
      nodejs
      procps # Added to resolve 'ps' dependency
      zlib
    ];
  };
  security.sudo = {
    enable = true;
    execWheelOnly = true; # Optional security measure
    wheelNeedsPassword = false;
  };
  users.users.ryzengrind = {
    isNormalUser = true;
    isSystemUser = true;
    hashedPassword = "$6$HI.fENQPPYsDtPh0$2zzBVFLjek./aHlwc0/AW5SdLNVQBixxYQnLyvcQhdFkNuIgT0KdHMTElFSiFd6PeK1.svjGw0zJnNkByQ3fn/";
    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPL6GOQ1zpvnxJK0Mz+vUHgEd0f/sDB0q3pa38yHHEsC ryzengrind@nixdevops.git"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILaDf9eWQpCOZfmuCwkc0kOH6ZerU7tprDlFTc+RHxCq ryzengrind@nixdevops.remote"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAitSzTpub1baCfA94ja3DNZpxd74kDSZ8RMLDwOZEOw ryzengrind@nixos.lan"
      #"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAitSzTpub1baCfA94ja3DNZpxd74kDSZ8RMLDwOZEOw ryzengrind@nixdevops.dev"
      #"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAitSzTpub1baCfA94ja3DNZpxd74kDSZ8RMLDwOZEOw ryzengrind@nixdevops.staging"
      #"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAitSzTpub1baCfA94ja3DNZpxd74kDSZ8RMLDwOZEOw ryzengrind@nixdevops.prod"
      #"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAitSzTpub1baCfA94ja3DNZpxd74kDSZ8RMLDwOZEOw ryzengrind@nixdevops.vmnet"
      #"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAitSzTpub1baCfA94ja3DNZpxd74kDSZ8RMLDwOZEOw absi@nixdevops.agent" # Artificial Benevolent Super Intelligence Agent for Nix-Dev-Ops-{dev,staging,prod,vmnet}
    ];

    shell = pkgs.fish;
    extraGroups = ["audio" "docker" "kvm" "libvirt" "libvirtd" "networkmanager" "podman" "qemu-libvirtd" "users" "video" "wheel"];
  };
  home-manager = {
    useGlobalPkgs = true; # Use the NixOS pkgs instead of creating a separate one
    useUserPackages = true; # Install packages to user profile
    extraSpecialArgs = {flakeInputs = inputs;}; # Place at Home Manager root level
    users.ryzengrind = import ./home.nix;
  };
  wsl = {
    enable = true;
    defaultUser = "ryzengrind";
    wslConf.network.hostname = "nix-pc";
    startMenuLaunchers = true;
    docker-desktop.enable = false;
  };
  #  systemd.services.wsl-vpnkit = {
  #    enable = true;
  #    description = "wsl-vpnkit";
  #    after = [ "network.target" ];
  #    serviceConfig = {
  #      ExecStart = "${pkgs.wsl-vpnkit}/bin/wsl-vpnkit";
  #      Restart = "always";
  #      KillMode = "mixed";
  #    };
  #  };
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
