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
  home-manager,
  ...
}: let
  # Define the usbip package based on kernel version
  usbipPackage =
    if pkgs.stdenv.hostPlatform.linux-kernel.name == "6.6"
    then pkgs.linuxKernel.packages.linux_6_6.usbip
    else pkgs.linuxPackages.usbip;
in {
  imports = [
    # inputs.nix-cfg.nixosModules.common-config # Temporarily commented out for debugging due to nix-cfg input removal
    opnix.nixosModules.default # Import opnix module directly
    nixos-wsl.nixosModules.default # Explicitly enable WSL module
    # Add more shared modules as needed
    home-manager.nixosModules.home-manager # Temporarily commented out for debugging
  ];

  boot = {
    kernelModules = ["usbip-core" "usbip-host" "vhci-hcd"];
    loader = {
      efi.canTouchEfiVariables = false; # Disable for WSL
      systemd-boot.enable = false; # Disable for WSL
    };
  };

  # Disable documentation options that might cause infinite recursion
  documentation.nixos.includeAllModules = false;

  environment = {
    pathsToLink = ["/share/bash-completion"];
    shellAliases = {
      # Clear any conflicting aliases
    };
    systemPackages = with pkgs; [
      _1password-gui-beta
      bash-completion # Better completion support
      bashInteractive # Replace regular bash
      binutils
      coreutils
      curl
      dconf2nix
      dnsutils
      fish
      gcc
      git
      glibc
      home-manager
      inetutils
      jq
      ncurses # Terminfo database
      neofetch
      nix-bash-completions
      nix-ld
      nixVersions.stable
      nixops-dns
      nixops_unstable_full
      #nixops_unstablePlugins.nixos-modules-contrib
      nodejs
      python3
      readline
      screen
      sd-switch
      starship
      usbip-ssh
      usbipPackage # Use the defined usbip package
      wget
      wsl-vpnkit
      zlib
    ];
  };

  i18n.defaultLocale = "en_CA.UTF-8";

  networking = {
    firewall = {
      allowedTCPPorts = [22 2222];
      enable = true;
    };
    networkmanager.enable = true;
  };

  nix.settings = {
    experimental-features = ["auto-allocate-uids" "ca-derivations" "cgroups" "dynamic-derivations" "fetch-closure" "fetch-tree" "flakes" "git-hashing" "local-overlay-store" "mounted-ssh-store" "no-url-literals" "pipe-operators" "nix-command" "recursive-nix"];
    trusted-users = ["root" "@wheel"];
  };

  # Set up proper nixpkgs configuration with overlays
  nixpkgs = {
    config = {
      allowBroken = true;
      allowUnfree = true;
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

  programs = {
    bash = {
      completion.enable = true;
      interactiveShellInit = ''
        # Initialize starship first
        eval "$(${pkgs.starship}/bin/starship init bash)"
      '';
      loginShellInit = ''
        nixos-wsl-welcome &&
        if [ "$WSL_NATIVE_SYSTEMD" = "true" ]; then
          echo "Updating Nix channel..." &&
          sudo nix-channel --update &&
          echo "Channels updated successfully." &&
          echo "Upgrading NixOS system..." &&
          sudo nixos-rebuild switch --upgrade --show-trace &&
          echo "NixOS system upgrade completed."
        fi
      '';
    };
    fish = {
      enable = true;
      interactiveShellInit = ''
        # Manual starship init for fish
        ${pkgs.starship}/bin/starship init fish | source
      '';
      loginShellInit = ''
        nixos-wsl-welcome
        if test (string match -r "true" (string escape --style=var (string escape --style=var $WSL_NATIVE_SYSTEMD)))
          echo "Updating Nix channel..."
          sudo nix-channel --update
          echo "Channels updated successfully."
          echo "Upgrading NixOS system..."
          sudo nixos-rebuild switch --upgrade --show-trace
          echo "NixOS system upgrade completed."
        end
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
    starship = {
      enable = true;
      settings = {
        add_newline = true;
        character = {
          error_symbol = "[❯](bold red)";
          success_symbol = "[❯](bold green)";
          vicmd_symbol = "[❮](bold blue)";
        };
        command_timeout = 5000;
        # Add explicit format wrapping
        format = "$all $character";
      };
    };
  };

  security.sudo = {
    enable = true;
    execWheelOnly = true; # Optional security measure
    wheelNeedsPassword = false;
  };

  services = {
    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "yes";
        UsePAM = true;
        X11Forwarding = true;
      };
    };
    xserver = {
      desktopManager.gnome.enable = false; # Adjust based on your GUI needs
      displayManager.gdm.enable = false; # Adjust based on your GUI needs
      enable = false; # Typically disabled for WSL, adjust based on your setup
    };
  };

  system = {
    autoUpgrade = {
      allowReboot = false; # Adjust for WSL, typically reboots are not managed through NixOS in WSL
      channel = "https://channels.nixos.org/nixos-25.05";
      enable = true;
    };
    stateVersion = "25.05"; # Did you read the comment?
  };

  systemd = {
    services = {
      "autovt@tty1".enable = false; # Disable autovt for WSL
      "getty@tty1".enable = false; # Disable getty for WSL
      NetworkManager-wait-online.enable = false;
      wsl-usbip-setup = {
        description = "Setup USBIP symlinks and modules for WSL";
        enable = true;
        serviceConfig = {
          ExecStart = pkgs.writeShellScript "wsl-usbip-setup" ''
            ${pkgs.coreutils}/bin/mkdir -p /usr/bin
            ${pkgs.coreutils}/bin/ln -sf ${pkgs.coreutils}/bin/ls /bin/ls
            # Robustly link usbip if available
            if [ -x "${usbipPackage}/bin/usbip" ]; then
              ${pkgs.coreutils}/bin/ln -sf ${usbipPackage}/bin/usbip /usr/bin/usbip
            elif [ -x "/run/current-system/sw/bin/usbip" ]; then
              ${pkgs.coreutils}/bin/ln -sf /run/current-system/sw/bin/usbip /usr/bin/usbip
            fi
            # Load required USBIP kernel modules
            ${pkgs.kmod}/bin/modprobe usbip-core || true
            ${pkgs.kmod}/bin/modprobe usbip-host || true
            ${pkgs.kmod}/bin/modprobe vhci-hcd || true
          '';
          Type = "oneshot";
        };
        wantedBy = ["multi-user.target"];
      };
    };
  };

  time.timeZone = "America/Toronto";

  users = {
    groups.docker.members = [
      config.wsl.defaultUser
    ];
    users.ryzengrind = {
      extraGroups = ["audio" "docker" "kvm" "libvirt" "libvirtd" "networkmanager" "podman" "qemu-libvirtd" "users" "video" "wheel"];
      hashedPassword = "$6$VOP1Yx5OUXwpOFaG$tVWf3Ai0.kzXpblhnatoeHHZb1xGKUuSEEQO79y1efrSyXR0sGmvFjo7oHbZBuQgZ3NFZi0MahU5hbyzsIwqq.";
      isNormalUser = true;
      isSystemUser = false;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILaDf9eWQpCOZfmuCwkc0kOH6ZerU7tprDlFTc+RHxCq ryzengrind@nixdevops.remote"
        # You can add other authorized keys here if needed, or manage them via Opnix if it exports a list of keys.
      ];
      shell = pkgs.fish;
    };
  };

  virtualisation.docker = {
    autoPrune.enable = true;
    enable = true;
    enableOnBoot = true;
  };

  wsl = {
    defaultUser = "ryzengrind";
    docker-desktop.enable = true;
    enable = true;
    extraBin = with pkgs; [
      {src = "${coreutils}/bin/cat";}
      {src = "${coreutils}/bin/whoami";}
      {src = "${su}/bin/groupadd";}
      {src = "${su}/bin/usermod";}
    ];
    startMenuLaunchers = true;
    tarball.configPath = ./configuration.nix;
    wslConf = {
      automount = {
        enabled = true;
        options = "metadata,umask=22,fmask=11,uid=1000,gid=100";
        root = "/mnt";
      };
      interop = {
        includePath = true;
        register = true;
      };
      network = {
        generateHosts = true;
        generateResolvConf = true;
        hostname = "pc";
      };
    };
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
  # If available in your NixOS version, enable the usbip service
  #services.usbip.enable = true;
}
