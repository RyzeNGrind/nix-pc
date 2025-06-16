# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL
{
  config,
  pkgs,
  lib,
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
    opnix.nixosModules.default
    nixos-wsl.nixosModules.default # Ensure WSL module is primary for WSL settings
    home-manager.nixosModules.home-manager
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
      usbutils
      curl
      dconf2nix
      dnsutils
      fish
      gcc
      git
      glibc
      home-manager # Keep if you use its executable
      inetutils
      jq
      ncurses # Terminfo database
      neofetch
      nix-bash-completions
      nix-ld
      nixVersions.stable # Or just 'nix' if you want the one from your nixpkgs input
      nixops-dns
      nixops_unstable_full
      # nixops_unstablePlugins.nixos-modules-contrib
      nodejs
      python3
      readline
      screen
      sd-switch
      starship
      tailscale # Add tailscale package
      usbip-ssh
      usbipPackage # Keep, ensures it's in the environment
      wget
      # wsl-vpnkit # You have this commented out later, ensure consistency
      zlib
      ripgrep
      # Environment packages for network management
      ethtool
      tcpdump
      bridge-utils
      vlan
      iproute2
      # Additional debugging tools
      networkmanager-l2tp
      openvpn
      wireguard-tools
      iperf3
      mtr
    ];
  };
  i18n.defaultLocale = "en_CA.UTF-8";
  # Fix the hosts file conflict
  environment.etc.hosts.source = lib.mkForce (pkgs.writeText "hosts" ''
    127.0.0.1 localhost
    ::1 localhost
    127.0.1.1 pc.lan pc
  '');
  # Consolidated networking configuration
  networking = {
    # This option is now IGNORED because we define per-interface settings.
    # useDHCP = true;
    useNetworkd = true;
    hostName = "pc";
    # This creates the vlanX@eth0 kernel devices.
    vlans = {
      "vlan5" = {
        id = 5;
        interface = "eth0";
      };
      "vlan10" = {
        id = 10;
        interface = "eth0";
      };
      "vlan20" = {
        id = 20;
        interface = "eth0";
      };
      "vlan25" = {
        id = 25;
        interface = "eth0";
      };
    };
    # This configures each interface with its unique MAC and enables DHCP.
    interfaces = {
      # Add eth0 configuration to ensure base interface is up
      eth0 = {
        useDHCP = true;
      };
      vlan5 = {
        useDHCP = true;
        # This assigns the correct MAC address for your static DHCP reservation.
        macAddress = "04:33:c2:b6:7b:91";
      };
      vlan10 = {
        useDHCP = true;
        macAddress = "04:33:c2:b6:7b:92";
      };
      vlan20 = {
        useDHCP = true;
        macAddress = "04:33:c2:b6:7b:93";
      };
      vlan25 = {
        useDHCP = true;
        macAddress = "04:33:c2:b6:7b:94";
      };
    };
    # Firewall configuration
    firewall = {
      enable = true;
      allowedTCPPorts = [22];
      # Trust VPN interfaces for high availability
      trustedInterfaces = ["tailscale0" "zt0"];
    };
  };
  nix.settings = {
    experimental-features = [
      "auto-allocate-uids"
      "ca-derivations"
      "cgroups"
      "dynamic-derivations"
      "fetch-closure"
      "fetch-tree"
      "flakes"
      "git-hashing"
      "local-overlay-store"
      "mounted-ssh-store"
      "no-url-literals"
      "pipe-operators"
      "nix-command"
      "recursive-nix"
    ];
    # Fixed: Use proper trusted-users setting instead of deprecated ones
    trusted-users = ["root" "@wheel" "ryzengrind"];
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
        # Robust agent/IDE terminal detection (Cursor, VSCode, Zed, Void, etc.)
        if [[ "$TERM_PROGRAM" =~ (vscode|cursor|zed|void) ]] || [[ -n "$VSCODE_IPC_HOOK_CLI" ]] || [[ -n "$CURSOR_AGENT" ]]; then
          export STARSHIP_DISABLED=1
          export PAGER=cat
          export GIT_PAGER=cat
          export LESS="--quit-if-one-screen"
          export BAT_PAGER=cat
          export MANPAGER=cat
          export SYSTEMD_COLORS=0
        fi
        # Initialize starship first (will be disabled above if needed)
        eval "$(${pkgs.starship}/bin/starship init bash)"
      '';
      loginShellInit = ''
        echo "Bash login shell initialized."
      '';
    };
    fish = {
      enable = true;
      interactiveShellInit = ''
        # Robust agent/IDE terminal detection (Cursor, VSCode, Zed, Void, etc.)
        if test "$TERM_PROGRAM" = "vscode" -o "$TERM_PROGRAM" = "cursor" -o "$TERM_PROGRAM" = "zed" -o "$TERM_PROGRAM" = "void" -o -n "$VSCODE_IPC_HOOK_CLI" -o -n "$CURSOR_AGENT"
          set -gx STARSHIP_DISABLED 1
          set -gx PAGER cat
          set -gx GIT_PAGER cat
          set -gx LESS "--quit-if-one-screen"
          set -gx BAT_PAGER cat
          set -gx MANPAGER cat
          set -gx SYSTEMD_COLORS 0
        end
        # Manual starship init for fish
        ${pkgs.starship}/bin/starship init fish | source
      '';
      loginShellInit = ''
        echo "Fish login shell initialized."
      '';
    };
    nix-ld.enable = true; # libraries can be added if specific unresolvable linking issues arise
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
        format = "$all $character";
      };
    };
  };
  security.sudo = {
    enable = true;
    execWheelOnly = true; # Optional security measure to ensure only wheel members have passwordless sudo
    wheelNeedsPassword = false;
  };
  services = {
    openssh = {
      enable = true;
      openFirewall = true; # May not be needed/effective in WSL mirrored networking mode
      settings = {
        PasswordAuthentication = true; # Consider disabling for security if using keys primarily
        PermitRootLogin = "yes"; # Change from "yes" to "no" after securing 1password ssh-agent to load ssh-keys for better security
        UsePAM = true;
        X11Forwarding = true;
      };
    };
    # Tailscale service configuration (instead of networking.tailscale)
    tailscale = {
      enable = true;
      openFirewall = true;
    };
    # ZeroTier service
    zerotierone = {
      enable = true;
      joinNetworks = ["9f77fc393e47072a"]; # Your ZeroTier network ID
    };
    # xserver settings typically not needed for WSLg, which handles GUI apps.
    xserver = {
      desktopManager.gnome.enable = false; # Adjust based on your GUI needs
      displayManager.gdm.enable = false; # Adjust based on your GUI needs
      enable = false; # Typically disabled for WSL, adjust based on your setup
    };
  };
  system = {
    autoUpgrade = {
      # Automatic upgrades can be tricky in WSL; ensure this behaves as expected or disable.
      # If enabled, ensure it uses the flake:
      # flake = inputs.self.outPath; # Or the correct path to your flake repo if /etc/nixos is not it
      allowReboot = false;
      channel = "https://channels.nixos.org/nixos-25.05"; # This is for non-flake systems. For flakes, updates come from flake inputs.
      enable = false; # Temporarily disable to avoid conflicts with flake management.
    };
    stateVersion = "25.05"; # Did you read the comment?
    configurationRevision = inputs.self.rev or "staging to dev"; # Simplified using 'or' operator
  };
  # CONSOLIDATED systemd configuration - FIXED: Single systemd block
  systemd = {
    # Fix the networkd wait-online timeout by disabling it or making it less strict
    services = {
      "autovt@tty1".enable = false; # Disable autovt for WSL
      "getty@tty1".enable = false; # Disable getty for WSL
      NetworkManager-wait-online.enable = false; # Not using NetworkManager

      # MAIN FIX: Disable systemd-networkd-wait-online entirely for WSL
      systemd-networkd-wait-online.enable = lib.mkForce false;

      # Alternative fix if you want to keep it but make it less strict:
      # systemd-networkd-wait-online = {
      #   serviceConfig = {
      #     ExecStart = lib.mkForce [
      #       "" # Clear the existing ExecStart
      #       "${pkgs.systemd}/lib/systemd/systemd-networkd-wait-online --timeout=10 --any --ignore=vlan5 --ignore=vlan10 --ignore=vlan20 --ignore=vlan25 --ignore=tailscale0 --ignore=zt0"
      #     ];
      #   };
      # };

      # Service to set VPN interface MAC addresses - IMPROVED
      set-vpn-macs = {
        description = "Set consistent MAC addresses for VPN interfaces";
        after = ["network-pre.target"];
        before = ["network.target"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = pkgs.writeShellScript "set-vpn-macs" ''
            # Wait for interfaces to appear with timeout
            timeout=30
            count=0
            while [ $count -lt $timeout ]; do
              # Check if at least one interface exists
              if ${pkgs.iproute2}/bin/ip link show zt0 &>/dev/null || ${pkgs.iproute2}/bin/ip link show tailscale0 &>/dev/null; then
                break
              fi
              sleep 1
              count=$((count + 1))
            done
            # Set ZeroTier MAC if interface exists
            if ${pkgs.iproute2}/bin/ip link show zt0 &>/dev/null; then
              echo "Setting ZeroTier MAC address..."
              ${pkgs.iproute2}/bin/ip link set dev zt0 address fe:8a:e6:78:32:5c || echo "Failed to set ZeroTier MAC"
            fi
            # Set Tailscale MAC if interface exists
            if ${pkgs.iproute2}/bin/ip link show tailscale0 &>/dev/null; then
              echo "Setting Tailscale MAC address..."
              ${pkgs.iproute2}/bin/ip link set dev tailscale0 address 00:15:5d:ef:04:0e || echo "Failed to set Tailscale MAC"
            fi
          '';
        };
      };
      # Add ZeroTier service override
      zerotierone = {
        serviceConfig = {
          Restart = lib.mkForce "on-failure";
        };
      };
    };
    # Additional systemd-networkd configuration to handle VLANs better
    network = {
      enable = true;
      networks = {
        # Base ethernet interface
        "10-eth0" = {
          matchConfig.Name = "eth0";
          dhcpV4Config.RouteMetric = 100;
          DHCP = "yes";
        };
        # VLAN configurations with higher metrics so they don't interfere with boot
        "20-vlan5" = {
          matchConfig.Name = "vlan5";
          dhcpV4Config.RouteMetric = 1005;
          DHCP = "yes";
        };
        "21-vlan10" = {
          matchConfig.Name = "vlan10";
          dhcpV4Config.RouteMetric = 1010;
          DHCP = "yes";
        };
        "22-vlan20" = {
          matchConfig.Name = "vlan20";
          dhcpV4Config.RouteMetric = 1020;
          DHCP = "yes";
        };
        "23-vlan25" = {
          matchConfig.Name = "vlan25";
          dhcpV4Config.RouteMetric = 1025;
          DHCP = "yes";
        };
      };
      netdevs = {
        # Define VLANs as netdevs for better control
        "vlan5" = {
          netdevConfig = {
            Kind = "vlan";
            Name = "vlan5";
          };
          vlanConfig.Id = 5;
        };
        "vlan10" = {
          netdevConfig = {
            Kind = "vlan";
            Name = "vlan10";
          };
          vlanConfig.Id = 10;
        };
        "vlan20" = {
          netdevConfig = {
            Kind = "vlan";
            Name = "vlan20";
          };
          vlanConfig.Id = 20;
        };
        "vlan25" = {
          netdevConfig = {
            Kind = "vlan";
            Name = "vlan25";
          };
          vlanConfig.Id = 25;
        };
      };
    };
  };
  time.timeZone = "America/Toronto";
  users = {
    groups.docker.members = [config.wsl.defaultUser];
    users.ryzengrind = {
      extraGroups = ["audio" "docker" "kvm" "libvirt" "libvirtd" "networkmanager" "podman" "qemu-libvirtd" "users" "video" "wheel"];
      hashedPassword = "$6$VOP1Yx5OUXwpOFaG$tVWf3Ai0.kzXpblhnatoeHHZb1xGKUuSEEQO79y1efrSyXR0sGmvFjo7oHbZBuQgZ3NFZi0MahU5hbyzsIwqq.";
      isNormalUser = true;
      # Add authorized keys from 1password op-ssh-agent
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILaDf9eWQpCOZfmuCwkc0kOH6ZerU7tprDlFTc+RHxCq ryzengrind@nixdevops.remote"
      ];
      shell = pkgs.fish;
    };
  };
  virtualisation.docker = {
    autoPrune.enable = true;
    enable = true;
    # enableOnBoot = true; # In WSL, services are usually started by systemd when the distro launches.
  };
  # WSL configuration with proper network settings
  wsl = {
    defaultUser = "ryzengrind";
    docker-desktop.enable = true; # Make sure this integrates well with virtualisation.docker.enable
    enable = true; # CRITICAL: This enables NixOS-WSL integration.
    usbip.enable = true; # CRITICAL: This enables USBIP support through the NixOS-WSL module.
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
        generateHosts = false; # Disabled to avoid conflicts
        generateResolvConf = false; # FIX: Let systemd-resolved manage DNS
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
# Deebo/MCP API key management: Ensure your API keys are set in ~/.cursor/mcp.json (Cursor) or ~/.deebo/.env (Deebo). For declarative management, consider using Home Manager secrets or sessionVariables.

