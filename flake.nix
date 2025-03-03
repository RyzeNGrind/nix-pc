{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nix-ld.url = "github:nix-community/nix-ld";  # Add this input
    nix-ld.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixos-wsl, nix-ld, ... }: {
    nixosConfigurations = {
      nix-pc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
	  nixos-wsl.nixosModules.wsl
        #  {
        #    system.stateVersion = "24.11";
        #    wsl.enable = true;
	#    wsl.defaultUser = "ryzengrind";
  	#    wsl.wslConf.network.hostname = "nix-pc";
        #  }
	#  ({ config, ... }: {
        #    nix.settings.experimental-features = [ "nix-command" "flakes" ];
        #  })
	#  nix-ld.nixosModules.nix-ld
        #  ({ ... }: {
        #    programs.nix-ld.dev.enable = true;
        #  })
	#  ({ pkgs, ... }: {
        #    environment.systemPackages = [
        #      pkgs.wget
        #      pkgs.jq
	#      pkgs.git
	#   #  pkgs.nix-ld
        #    ];
        #  })
        ];
      };
    };
  };
}
