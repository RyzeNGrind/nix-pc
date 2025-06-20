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
  opnix,
  nixos-wsl,
  ...
}: {
  imports = [
    # inputs.nix-cfg.nixosModules.common-config # Temporarily commented out for debugging due to nix-cfg input removal
    opnix.nixosModules.default # Import opnix module directly
    nixos-wsl.nixosModules.default # Explicitly enable WSL module
    # Add more shared modules as needed
    # inputs.home-manager.nixosModules.home-manager # Temporarily commented out for debugging
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
      linuxPackages.usbip
    ];
  };
  security.sudo = {
    enable = true;
    execWheelOnly = true; # Optional security measure
    wheelNeedsPassword = false;
  };
  users.users.ryzengrind = {
    isNormalUser = true;
    isSystemUser = false;
    hashedPassword = "$6$HI.fENQPPYsDtPh0$2zzBVFLjek./aHlwc0/AW5SdLNVQBixxYQnLyvcQhdFkNuIgT0KdHMTElFSiFd6PeK1.svjGw0zJnNkByQ3fn/";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILaDf9eWQpCOZfmuCwkc0kOH6ZerU7tprDlFTc+RHxCq ryzengrind@nixdevops.remote"
      # You can add other authorized keys here if needed, or manage them via Opnix if it exports a list of keys.
    ];
    shell = pkgs.fish;
    extraGroups = ["audio" "docker" "kvm" "libvirt" "libvirtd" "networkmanager" "podman" "qemu-libvirtd" "users" "video" "wheel"];
  };
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "yes";
      X11Forwarding = true;
      UsePAM = true;
    };
    openFirewall = true;
  };
  wsl = {
    enable = true;
    defaultUser = "ryzengrind";
    wslConf.network.hostname = "pc";
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
  boot.kernelModules = ["usbip-core" "usbip-host" "vhci-hcd"];
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [22 2222];
}
