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
        ...
      }: {
        #pre-commit.settings.hooks = import ./git-hooks.nix {inherit pkgs;};
        pre-commit.settings.hooks = import ./git-hooks.nix;

        # Development Shell
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
            fzf
            zoxide
            direnv
          ];
          shellHook = ''
            ${config.pre-commit.installationScript}
            # Agentic aliases for fast Nix workflows
            if [ -n "$BASH_VERSION" ]; then
              alias nfc='nix run github:Mic92/nix-fast-build -- --flake ".#checks.$(nix eval --impure --raw --expr "builtins.currentSystem")"'
              alias nfco='nix flake check'
              alias fastcheck='nix run github:Mic92/nix-fast-build -- --flake ".#checks.$(nix eval --impure --raw --expr "builtins.currentSystem")"'
              alias fastdev='nix run github:Mic92/nix-fast-build -- --flake ".#devShells.$(nix eval --impure --raw --expr "builtins.currentSystem").default"'
            fi
            if [ -n "$FISH_VERSION" ]; then
              alias nfc "nix run github:Mic92/nix-fast-build -- --flake .#checks.(nix eval --impure --raw --expr 'builtins.currentSystem')"
              alias nfco "nix flake check"
              alias fastcheck "nix run github:Mic92/nix-fast-build -- --flake .#checks.(nix eval --impure --raw --expr 'builtins.currentSystem')"
              alias fastdev "nix run github:Mic92/nix-fast-build -- --flake .#devShells.(nix eval --impure --raw --expr 'builtins.currentSystem').default"
            end
            echo "[nix-pc] Aliases: nfc (fast check), nfco (flake check), fastcheck, fastdev loaded."
          '';
        };
        #checks.pre-commit = config.pre-commit.check;
      };
      # Global flake attributes (not per-system)
      flake = {
        overlays = import ./overlays {
          inherit nixpkgs-unstable;
        };
        nixosConfigurations.pc = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {inherit inputs opnix nixos-wsl;};
          modules = [
            ./configuration.nix
          ];
        };
      };
    };
  in
    flakeParts;
}
