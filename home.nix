{pkgs, ...}: {
  home = {
    username = "ryzengrind";
    homeDirectory = "/home/ryzengrind";
    stateVersion = "25.05"; # Or your current HM release version

    # You can also put home.packages here if you prefer
    # packages = with pkgs; [ ... ];
    enableNixpkgsReleaseCheck = true;
    sessionVariables = {
      SSH_AUTH_SOCK = "/mnt/c/Users/RyzeNGrind/.1password/agent.sock";
    };
  };

  programs = {
    fish = {
      enable = true;
      interactiveShellInit = ''
        # Manual starship init for fish
        ${pkgs.starship}/bin/starship init fish | source
        # VS Code/Cursor/Void shell integration for Fish (WSL2/NixOS)
        for script in \
          "/mnt/c/Program Files/Microsoft VS Code/resources/app/out/vs/workbench/contrib/terminal/common/scripts/shellIntegration.fish" \
          "/mnt/c/Program Files/cursor/resources/app/out/vs/workbench/contrib/terminal/common/scripts/shellIntegration.fish" \
          "/mnt/c/Program Files/Void/resources/app/out/vs/workbench/contrib/terminal/common/scripts/shellIntegration.fish"
          if test -f $script
            source $script
          end
        end
        # Set SSH_AUTH_SOCK for 1Password agent in WSL2
        set -gx SSH_AUTH_SOCK /mnt/c/Users/RyzeNGrind/.1password/agent.sock
      '';
    };

    bash = {
      enable = true;
      shellInit = ''
        # VS Code/Cursor/Void shell integration for Bash (WSL2/NixOS)
        for script in \
          "/mnt/c/Program Files/Microsoft VS Code/resources/app/out/vs/workbench/contrib/terminal/common/scripts/shellIntegration-bash.sh" \
          "/mnt/c/Program Files/cursor/resources/app/out/vs/workbench/contrib/terminal/common/scripts/shellIntegration-bash.sh" \
          "/mnt/c/Program Files/Void/resources/app/out/vs/workbench/contrib/terminal/common/scripts/shellIntegration-bash.sh"
        do
          if [ -f "$script" ]; then
            source "$script"
          fi
        done
        # Set SSH_AUTH_SOCK for 1Password agent in WSL2
        export SSH_AUTH_SOCK=/mnt/c/Users/RyzeNGrind/.1password/agent.sock
      '';
    };

    starship = {
      enable = true;
      # ... starship settings
    };
  };

  # If you have home.packages, it can stay separate or be moved into the main home attribute set
  # For example:
  # home.packages = with pkgs; [
  #   neovim
  # ];
  # Or inside the main home block:
  # home = {
  #   ...
  #   packages = with pkgs; [ neovim ];
  # };

  programs.onepassword-secrets = {
    enable = true;
    secrets = [
      # Main NixOS key (used for all NixOS installs)
      {
        path = ".ssh/id_ed25519";
        reference = "op://Personal/ssh-key/private-key";
        # SHA256:f6AulKkaymkDcDJzYQsAQeYVR89dDE7A3ctIzdbK5gM
        # Tag: nixos
      }
      # GitHub signing key
      {
        path = ".ssh/id_ed25519_git";
        reference = "op://Personal/ryzengrind@git/private_key";
        # SHA256:rzzSJEyDzKoSrwYXECwl4xR8rhwwcVXQd9KeeCA7/qw
        # Tag: git, sign
      }
      # Oracle Cloud (OCI) key
      {
        path = ".ssh/id_ed25519_oci";
        reference = "op://Personal/ryzengrind@oci/private_key";
        # SHA256:O5yIUlPYQ96YIDQ3+BcQe8v4p/xF0G9kzqwqn/HmZKU
        # Tag: oci, prod
      }
      # Gitpod key
      {
        path = ".ssh/id_ed25519_gitpod";
        reference = "op://Personal/ryzengrind@gitpod/private_key";
        # SHA256:3Qw44k8N05tZeeEdhh/+iSSolyCVGBTDgkej3sf8OQo
        # Tag: gitpod, dev
      }
      # Termius key (for Termius client, PiCluster, etc.)
      {
        path = ".ssh/id_ed25519_termius";
        reference = "op://Personal/ryzengrind@termius/private_key";
        # SHA256:8YJPBrtescDNVsB5GMEtPG9WBCiKlctRzJcKykXlgoA
        # Tag: termius, dev
      }
    ];
  };

  imports = [
    # To import a local module like 1password-ssh.nix (if it exists relative to this file):
    # "${./modules/1password-ssh.nix}"
    # If you intend to share this module from nix-cfg, import it like:
    # inputs.nix-cfg.homeManagerModules."1password-ssh-agent" # (assuming it's a Home Manager module there)
  ];
}
