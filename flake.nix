{
  description = "NixOS configurations for baremetal and WSL development/server/cluster environments";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05"; # Updated to 25.05 to match HM
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05"; # Matched to nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Flake-parts for structure
    flake-parts.url = "github:hercules-ci/flake-parts";
    # git-hooks.nix for managing pre-commit hooks via Nix
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Other inputs
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nix-ld.url = "github:nix-community/nix-ld";
    opnix.url = "github:brizzbuzz/opnix";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nix-cfg.url = "path:/home/ryzengrind/nix-cfg"; # Re-enabling nix-cfg input
  };
  outputs = inputs @ {
    nixpkgs,
    home-manager,
    nixpkgs-unstable,
    flake-parts,
    git-hooks-nix,
    opnix,
    nixos-wsl,
    ...
  }: let
    flakeParts = flake-parts.lib.mkFlake {inherit inputs;} {
      # `inputs` (no prime) is the full attrset of flake inputs passed to mkFlake
      imports = [
        git-hooks-nix.flakeModule
      ];
      systems = ["x86_64-linux"]; # Specify supported systems for perSystem attributes
      # Use `inputs'` (with prime) in the signature here, as guided by flake-parts error message
      perSystem = {
        config,
        pkgs,
        inputs',
        #lib, # Removed unused lib parameter
        ...
      }: {
        # Inlined pre-commit hook definitions from git-hooks.nix
        pre-commit.settings.hooks = {
          alejandra = {
            enable = true;
          };
          deadnix = {
            enable = true;
          };
          statix = {
            enable = true;
          };
          prettier = {
            enable = true;
            types_or = ["markdown" "yaml" "json"];
          };
          # This hook was causing issues, disabling for now. Re-enable with proper configuration if needed.
          # nixos-config-tests = {
          #   enable = false;
          #   name = "NixOS Configuration Tests";
          #   entry = "";
          #   language = "script";
          #   pass_filenames = false;
          # };
        };
        devShells.default = pkgs.mkShell {
          name = "nix-config-dev-shell";
          packages = with pkgs; [
            # pkgs is inputs'.nixpkgs.legacyPackages for the current system
            alejandra
            deadnix
            statix
            nodePackages.prettier
            # Git and pre-commit
            git
            gh
            pre-commit
            nixpkgs-fmt
            nil
            nix-output-monitor
            inputs'.home-manager.packages.default
            starship
            bashInteractive
            bash-completion
            nix-bash-completions
            fzf
            zoxide
            direnv
            inputs'.nixpkgs.legacyPackages.nix-fast-build
            nixVersions.stable
            nixops-dns
            nixops_unstable_full
          ];
          shellHook = ''
            ${config.pre-commit.installationScript}
            # Ensure git hooks are properly installed
            if [ ! -f .git/hooks/pre-commit ]; then
              echo "Installing git hooks..."
              pre-commit install
            fi
            # Aliases for nix-fast-build
            alias fastnixos='nix-fast-build -f .#nixosConfigurations.pc.config.system.build.toplevel'
            alias fastcheck='nix-fast-build -f .#checks.x86_64-linux.pre-commit'
            echo "NixOS Configuration Development Shell activated!"
            echo "Available commands:"
            echo "  pre-commit run --all-files              # Run all hooks"
            echo "  pre-commit run <hook_name> --all-files  # Run specific hook"
            echo "  fastnixos                               # Build NixOS config"
            echo "  fastcheck                               # Run pre-commit checks"
            # VS Code/Cursor/Void shell integration for bash (WSL2)
            case "$TERM_PROGRAM" in
              "vscode")
                source "/mnt/c/Program Files/Microsoft VS Code/resources/app/out/vs/workbench/contrib/terminal/common/scripts/shellIntegration-bash.sh" 2>/dev/null || true
                ;;
              "cursor")
                source "/mnt/c/Program Files/cursor/resources/app/out/vs/workbench/contrib/terminal/common/scripts/shellIntegration-bash.sh" 2>/dev/null || true
                ;;
              "void")
                source "/mnt/c/Program Files/Void/resources/app/out/vs/workbench/contrib/terminal/common/scripts/shellIntegration-bash.sh" 2>/dev/null || true
                ;;
            esac
          '';
        };
        checks.helloCheck = pkgs.runCommand "helloCheck" {} ''
          ${pkgs.hello}/bin/hello > $out
        '';
      };
      # Global flake attributes (not per-system)
      flake = {
        overlays = import ./overlays {
          inherit nixpkgs-unstable;
        };
        nixosConfigurations.pc = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {inherit inputs opnix nixos-wsl home-manager;};
          modules = [
            ./configuration.nix
          ];
        };
      };
    };
  in
    flakeParts;
}
