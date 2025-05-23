{
  description = "NixOS configurations for baremetal and WSL development/server/cluster environments";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    # You can access packages and modules from different nixpkgs revs
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Pre-commit hooks
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NixOS-WSL
    nixos-wsl.url = "github:nix-community/nixos-wsl";
    nix-ld = {
      url = "github:nix-community/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # 1Password integration
    opnix = {
      url = "github:brizzbuzz/opnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Hardware configuration
    nixos-hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    pre-commit-hooks,
    nixos-wsl,
    home-manager,
    ...
  } @ inputs: let
    # Only build for Linux systems
    # For packages that can build on any system
    allSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs allSystems;

    # Define overlays
    overlays = {
      default = import ./overlays/default-bash.nix;
      unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit (prev) system;
          config.allowUnfree = true;
        };
      };
    };
  in {
    inherit overlays;
    # Add checks for pre-commit hooks
    checks = forAllSystems (system: {
      pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          alejandra = {
            enable = true;
            excludes = ["^modules/nixos/cursor/.*$"];
            settings.verbosity = "quiet";
          };
          deadnix = {
            enable = true;
            excludes = ["^modules/nixos/cursor/.*$"];
            settings.noLambdaPatternNames = true;
          };
          statix = {
            enable = true;
            excludes = ["^modules/nixos/cursor/.*$"];
          };
          prettier = {
            enable = true;
            excludes = [
              "^modules/nixos/cursor/.*$"
              "^.vscode/settings.json$"
            ];
            types_or = [
              "markdown"
              "yaml"
              "json"
            ];
          };
          test-flake = {
            enable = true;
            name = "NixOS Configuration Tests";
            entry = "scripts/test-flake.sh";
            language = "system";
            pass_filenames = false;
            stages = ["commit"];
            always_run = true;
          };
        };
      };
    });

    # Your custom packages and modifications
    devShells = forAllSystems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            cudaSupport = system == "x86_64-linux" || system == "aarch64-linux";
            amdgpuSupport = system == "x86_64-linux" || system == "aarch64-linux";
            experimental-features = ["nix-command" "flakes" "repl-flake" "recursive-nix" "fetch-closure" "dynamic-derivations" "daemon-trust-override" "cgroups" "ca-derivations" "auto-allocate-uids" "impure-derivations"];
          };
        };
      in {
        default = pkgs.mkShell {
          name = "nix-config-dev-shell";
          nativeBuildInputs = with pkgs; [
            # Formatters and linters
            alejandra
            deadnix
            statix
            nodePackages.prettier

            # Git and pre-commit
            git
            pre-commit

            # Nix tools
            nixpkgs-fmt
            nil
            nix-output-monitor
            home-manager.packages.${system}.default
            starship
            bashInteractive
            bash-completion
            bash-preexec
            fzf
            zoxide
            direnv
          ];
          shellHook = builtins.readFile ./scripts/bin/devShellHook.sh;
        };
      }
    );

    nixosConfigurations = {
      nix-pc = let
        system = "x86_64-linux";
      in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            nixos-wsl = inputs.nixos-wsl;
            home-manager = inputs.home-manager; # Pass home-manager
            opnix = inputs.opnix; # Pass opnix
          };
          modules = [
            ./configuration.nix
          ];
        };
    };
  };
}
