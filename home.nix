{pkgs, ...}: {
  home = {
    username = "ryzengrind";
    homeDirectory = "/home/ryzengrind";
    stateVersion = "25.05"; # Or your current HM release version

    # You can also put home.packages here if you prefer
    # packages = with pkgs; [ ... ];
    enableNixpkgsReleaseCheck = true;
  };

  programs = {
    fish = {
      enable = true;
      interactiveShellInit = ''
        # Manual starship init for fish
        ${pkgs.starship}/bin/starship init fish | source
      '';
    };

    bash = {
      enable = true;
      # ... other bash settings
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
