diff --git a/configuration.nix b/configuration.nix
index 7d67684..d7c5cfb 100644
--- a/configuration.nix
+++ b/configuration.nix
@@ -5,8 +5,8 @@
 # https://github.com/nix-community/NixOS-WSL
 {
   config,
-  lib,
   pkgs,
+  #lib,
   inputs,
   ...
 }: {
diff --git a/flake.lock b/flake.lock
index 647bfac..af0a16c 100644
--- a/flake.lock
+++ b/flake.lock
@@ -3,11 +3,11 @@
     "flake-compat": {
       "flake": false,
       "locked": {
-        "lastModified": 1733328505,
-        "narHash": "sha256-NeCCThCEP3eCl2l/+27kNNK7QrwZB1IJCrXfrbv5oqU=",
+        "lastModified": 1696426674,
+        "narHash": "sha256-kvjfFW7WAETZlt09AgDn1MrtKzP7t90Vf7vypd3OL1U=",
         "owner": "edolstra",
         "repo": "flake-compat",
-        "rev": "ff81ac966bb2cae68946d5ed5fc4994f96d0ffec",
+        "rev": "0f9255e01c2351cc7d116c072cb317785dd33b33",
         "type": "github"
       },
       "original": {
@@ -19,11 +19,11 @@
     "flake-compat_2": {
       "flake": false,
       "locked": {
-        "lastModified": 1696426674,
-        "narHash": "sha256-kvjfFW7WAETZlt09AgDn1MrtKzP7t90Vf7vypd3OL1U=",
+        "lastModified": 1733328505,
+        "narHash": "sha256-NeCCThCEP3eCl2l/+27kNNK7QrwZB1IJCrXfrbv5oqU=",
         "owner": "edolstra",
         "repo": "flake-compat",
-        "rev": "0f9255e01c2351cc7d116c072cb317785dd33b33",
+        "rev": "ff81ac966bb2cae68946d5ed5fc4994f96d0ffec",
         "type": "github"
       },
       "original": {
@@ -32,6 +32,24 @@
         "type": "github"
       }
     },
+    "flake-parts": {
+      "inputs": {
+        "nixpkgs-lib": "nixpkgs-lib"
+      },
+      "locked": {
+        "lastModified": 1743550720,
+        "narHash": "sha256-hIshGgKZCgWh6AYJpJmRgFdR3WUbkY04o82X05xqQiY=",
+        "owner": "hercules-ci",
+        "repo": "flake-parts",
+        "rev": "c621e8422220273271f52058f618c94e405bb0f5",
+        "type": "github"
+      },
+      "original": {
+        "owner": "hercules-ci",
+        "repo": "flake-parts",
+        "type": "github"
+      }
+    },
     "flake-utils": {
       "inputs": {
         "systems": "systems"
@@ -50,9 +68,29 @@
         "type": "github"
       }
     },
+    "git-hooks-nix": {
+      "inputs": {
+        "flake-compat": "flake-compat",
+        "gitignore": "gitignore",
+        "nixpkgs": ["nixpkgs"]
+      },
+      "locked": {
+        "lastModified": 1747372754,
+        "narHash": "sha256-2Y53NGIX2vxfie1rOW0Qb86vjRZ7ngizoo+bnXU9D9k=",
+        "owner": "cachix",
+        "repo": "git-hooks.nix",
+        "rev": "80479b6ec16fefd9c1db3ea13aeb038c60530f46",
+        "type": "github"
+      },
+      "original": {
+        "owner": "cachix",
+        "repo": "git-hooks.nix",
+        "type": "github"
+      }
+    },
     "gitignore": {
       "inputs": {
-        "nixpkgs": ["pre-commit-hooks", "nixpkgs"]
+        "nixpkgs": ["git-hooks-nix", "nixpkgs"]
       },
       "locked": {
         "lastModified": 1709087332,
@@ -89,7 +127,7 @@
     },
     "nix-ld": {
       "inputs": {
-        "nixpkgs": ["nixpkgs"]
+        "nixpkgs": "nixpkgs"
       },
       "locked": {
         "lastModified": 1744621833,
@@ -122,8 +160,8 @@
     },
     "nixos-wsl": {
       "inputs": {
-        "flake-compat": "flake-compat",
-        "nixpkgs": "nixpkgs"
+        "flake-compat": "flake-compat_2",
+        "nixpkgs": "nixpkgs_2"
       },
       "locked": {
         "lastModified": 1744290088,
@@ -141,20 +179,35 @@
     },
     "nixpkgs": {
       "locked": {
-        "lastModified": 1742937945,
-        "narHash": "sha256-lWc+79eZRyvHp/SqMhHTMzZVhpxkRvthsP1Qx6UCq0E=",
+        "lastModified": 1748370509,
+        "narHash": "sha256-QlL8slIgc16W5UaI3w7xHQEP+Qmv/6vSNTpoZrrSlbk=",
         "owner": "NixOS",
         "repo": "nixpkgs",
-        "rev": "d02d88f8de5b882ccdde0465d8fa2db3aa1169f7",
+        "rev": "4faa5f5321320e49a78ae7848582f684d64783e9",
         "type": "github"
       },
       "original": {
         "owner": "NixOS",
-        "ref": "nixos-24.11",
+        "ref": "nixos-unstable",
         "repo": "nixpkgs",
         "type": "github"
       }
     },
+    "nixpkgs-lib": {
+      "locked": {
+        "lastModified": 1743296961,
+        "narHash": "sha256-b1EdN3cULCqtorQ4QeWgLMrd5ZGOjLSLemfa00heasc=",
+        "owner": "nix-community",
+        "repo": "nixpkgs.lib",
+        "rev": "e4822aea2a6d1cdd36653c134cacfd64c97ff4fa",
+        "type": "github"
+      },
+      "original": {
+        "owner": "nix-community",
+        "repo": "nixpkgs.lib",
+        "type": "github"
+      }
+    },
     "nixpkgs-unstable": {
       "locked": {
         "lastModified": 1744463964,
@@ -172,6 +225,22 @@
       }
     },
     "nixpkgs_2": {
+      "locked": {
+        "lastModified": 1742937945,
+        "narHash": "sha256-lWc+79eZRyvHp/SqMhHTMzZVhpxkRvthsP1Qx6UCq0E=",
+        "owner": "NixOS",
+        "repo": "nixpkgs",
+        "rev": "d02d88f8de5b882ccdde0465d8fa2db3aa1169f7",
+        "type": "github"
+      },
+      "original": {
+        "owner": "NixOS",
+        "ref": "nixos-24.11",
+        "repo": "nixpkgs",
+        "type": "github"
+      }
+    },
+    "nixpkgs_3": {
       "locked": {
         "lastModified": 1748437600,
         "narHash": "sha256-hYKMs3ilp09anGO7xzfGs3JqEgUqFMnZ8GMAqI6/k04=",
@@ -187,10 +256,26 @@
         "type": "github"
       }
     },
+    "nixpkgs_4": {
+      "locked": {
+        "lastModified": 1748370509,
+        "narHash": "sha256-QlL8slIgc16W5UaI3w7xHQEP+Qmv/6vSNTpoZrrSlbk=",
+        "owner": "NixOS",
+        "repo": "nixpkgs",
+        "rev": "4faa5f5321320e49a78ae7848582f684d64783e9",
+        "type": "github"
+      },
+      "original": {
+        "owner": "NixOS",
+        "ref": "nixos-unstable",
+        "repo": "nixpkgs",
+        "type": "github"
+      }
+    },
     "opnix": {
       "inputs": {
         "flake-utils": "flake-utils",
-        "nixpkgs": ["nixpkgs"]
+        "nixpkgs": "nixpkgs_4"
       },
       "locked": {
         "lastModified": 1746544287,
@@ -206,36 +291,17 @@
         "type": "github"
       }
     },
-    "pre-commit-hooks": {
-      "inputs": {
-        "flake-compat": "flake-compat_2",
-        "gitignore": "gitignore",
-        "nixpkgs": ["nixpkgs"]
-      },
-      "locked": {
-        "lastModified": 1742649964,
-        "narHash": "sha256-DwOTp7nvfi8mRfuL1escHDXabVXFGT1VlPD1JHrtrco=",
-        "owner": "cachix",
-        "repo": "pre-commit-hooks.nix",
-        "rev": "dcf5072734cb576d2b0c59b2ac44f5050b5eac82",
-        "type": "github"
-      },
-      "original": {
-        "owner": "cachix",
-        "repo": "pre-commit-hooks.nix",
-        "type": "github"
-      }
-    },
     "root": {
       "inputs": {
+        "flake-parts": "flake-parts",
+        "git-hooks-nix": "git-hooks-nix",
         "home-manager": "home-manager",
         "nix-ld": "nix-ld",
         "nixos-hardware": "nixos-hardware",
         "nixos-wsl": "nixos-wsl",
-        "nixpkgs": "nixpkgs_2",
+        "nixpkgs": "nixpkgs_3",
         "nixpkgs-unstable": "nixpkgs-unstable",
-        "opnix": "opnix",
-        "pre-commit-hooks": "pre-commit-hooks"
+        "opnix": "opnix"
       }
     },
     "systems": {
diff --git a/flake.nix b/flake.nix
index 19ea685..7727255 100644
--- a/flake.nix
+++ b/flake.nix
@@ -1,158 +1,107 @@
 {
   description = "NixOS configurations for baremetal and WSL development/server/cluster environments";
   inputs = {
-    # Nixpkgs
-    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
-    # You can access packages and modules from different nixpkgs revs
+    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05"; # Updated to 25.05 to match HM
     nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
-    # Home manager
+
     home-manager = {
-      url = "github:nix-community/home-manager/release-25.05";
+      url = "github:nix-community/home-manager/release-25.05"; # Matched to nixpkgs
       inputs.nixpkgs.follows = "nixpkgs";
     };
-    # Pre-commit hooks
-    pre-commit-hooks = {
-      url = "github:cachix/pre-commit-hooks.nix";
+
+    # Flake-parts for structure
+    flake-parts.url = "github:hercules-ci/flake-parts";
+
+    # git-hooks.nix for managing pre-commit hooks via Nix
+    git-hooks-nix = {
+      url = "github:cachix/git-hooks.nix";
       inputs.nixpkgs.follows = "nixpkgs";
     };
-    # NixOS-WSL
+
+    # Other inputs
     nixos-wsl.url = "github:nix-community/nixos-wsl";
-    nix-ld = {
-      url = "github:nix-community/nix-ld";
-      inputs.nixpkgs.follows = "nixpkgs";
-    };
-    # 1Password integration
-    opnix = {
-      url = "github:brizzbuzz/opnix";
-      inputs.nixpkgs.follows = "nixpkgs";
-    };
-    # Hardware configuration
+    nix-ld.url = "github:nix-community/nix-ld";
+    opnix.url = "github:brizzbuzz/opnix"; # Assuming nixpkgs follow is desired
     nixos-hardware.url = "github:nixos/nixos-hardware";
   };
-  outputs = {
-    self,
+
+  outputs = inputs @ {
     nixpkgs,
-    nixpkgs-unstable,
-    pre-commit-hooks,
-    nixos-wsl,
     home-manager,
+    nixpkgs-unstable,
+    flake-parts,
+    git-hooks-nix,
     ...
-  } @ inputs: let
-    # Only build for Linux systems
-    # For packages that can build on any system
-    allSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
-    forAllSystems = nixpkgs.lib.genAttrs allSystems;
-    # Define overlays
-    overlays = {
-      default = _final: _prev: {
-        # Add any custom packages here if needed
-      };
-      unstable = _final: prev: {
-        unstable = import nixpkgs-unstable {
-          inherit (prev) system;
-          config.allowUnfree = true;
-        };
-      };
-    };
-  in {
-    inherit overlays;
-    # Add checks for pre-commit hooks
-    checks = forAllSystems (system: {
-      pre-commit-check = pre-commit-hooks.lib.${system}.run {
-        src = ./.;
-        hooks = {
-          alejandra = {
-            enable = true;
-            excludes = ["^modules/nixos/cursor/.*$"];
-            settings.verbosity = "quiet";
-          };
-          deadnix = {
-            enable = true;
-            excludes = ["^modules/nixos/cursor/.*$"];
-            settings.noLambdaPatternNames = true;
-          };
-          statix = {
-            enable = true;
-            excludes = ["^modules/nixos/cursor/.*$"];
-          };
-          prettier = {
-            enable = true;
-            excludes = [
-              "^modules/nixos/cursor/.*$"
-              "^.vscode/settings.json$"
-            ];
-            types_or = [
-              "markdown"
-              "yaml"
-              "json"
-            ];
-          };
-          test-flake = {
-            enable = true;
-            name = "NixOS Configuration Tests";
-            entry = "scripts/test-flake.sh";
-            language = "system";
-            pass_filenames = false;
-            stages = ["manual"];
-            always_run = true;
-          };
-        };
-      };
-    });
-    # Your custom packages and modifications
-    devShells = forAllSystems (
-      system: let
-        pkgs = import nixpkgs {
-          inherit system;
-          config = {
-            allowUnfree = true;
-            cudaSupport = system == "x86_64-linux" || system == "aarch64-linux";
-            amdgpuSupport = system == "x86_64-linux" || system == "aarch64-linux";
-            experimental-features = ["nix-command" "flakes" "repl-flake" "recursive-nix" "fetch-closure" "dynamic-derivations" "daemon-trust-override" "cgroups" "ca-derivations" "auto-allocate-uids" "impure-derivations"];
-          };
-        };
-      in {
-        default = pkgs.mkShell {
+  }:
+    flake-parts.lib.mkFlake {inherit inputs;} {
+      # `inputs` (no prime) is the full attrset of flake inputs passed to mkFlake
+      imports = [
+        git-hooks-nix.flakeModule
+      ];
+
+      systems = ["x86_64-linux"]; # Specify supported systems for perSystem attributes
+
+      # Use `inputs'` (with prime) in the signature here, as guided by flake-parts error message
+      perSystem = {
+        config,
+        pkgs,
+        inputs',
+        ...
+      }: {
+        #pre-commit.settings.hooks = import ./git-hooks.nix {inherit pkgs;};
+        pre-commit.settings.hooks = import ./git-hooks.nix;
+
+        # Development Shell
+        devShells.default = pkgs.mkShell {
           name = "nix-config-dev-shell";
-          nativeBuildInputs = with pkgs; [
-            # Formatters and linters
+          packages = with pkgs; [
+            # pkgs is inputs'.nixpkgs.legacyPackages for the current system
             alejandra
             deadnix
             statix
             nodePackages.prettier
             # Git and pre-commit
             git
-            pre-commit
-            # Nix tools
             nixpkgs-fmt
             nil
             nix-output-monitor
-            home-manager.packages.${system}.default
+            inputs'.home-manager.packages.default
             starship
             bashInteractive
             bash-completion
-            bash-preexec
             fzf
             zoxide
             direnv
+            # Add procps for 'ps' command needed by your test script
+            procps
           ];
-          shellHook = builtins.readFile ./scripts/bin/devShellHook.sh;
+
+          shellHook = ''
+            ${config.pre-commit.installationScript}
+            echo "NixOS Configuration Development Shell (with git-hooks.nix) activated!"
+            echo "Relevant pre-commit commands:"
+            echo "  pre-commit install                      # (Re-)Install hooks to .git/"
+            echo "  pre-commit run --all-files              # Run all hooks on all files"
+            echo "  pre-commit run <hook_id> --all-files    # Run a specific hook"
+            # cat ${./scripts/bin/devShellHook.sh}
+          '';
         };
-      }
-    );
-    nixosConfigurations = {
-      nix-pc = let
-        system = "x86_64-linux";
-      in
-        nixpkgs.lib.nixosSystem {
-          inherit system;
-          specialArgs = {
-            inherit inputs;
-          };
+
+        #checks.pre-commit = config.pre-commit.check;
+      };
+
+      # Global flake attributes (not per-system)
+      flake = {
+        overlays = import ./overlays {
+          inherit nixpkgs-unstable;
+        }; # Top-level inputs
+        nixosConfigurations.nix-pc = nixpkgs.lib.nixosSystem {
+          system = "x86_64-linux";
+          specialArgs = {inherit inputs;}; # Top-level inputs
           modules = [
             ./configuration.nix
           ];
         };
+      };
     };
-  };
 }
diff --git a/home.nix b/home.nix
index 983c545..759b166 100644
--- a/home.nix
+++ b/home.nix
@@ -1,10 +1,4 @@
-{
-  config,
-  pkgs,
-  lib,
-  flakeInputs,
-  ...
-}: {
+{pkgs, ...}: {
   home = {
     username = "ryzengrind";
     homeDirectory = "/home/ryzengrind";
