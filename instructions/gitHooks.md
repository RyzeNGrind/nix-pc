Here is your revised, pure Nix, flake-parts + git-hooks.nix instruction for LLMs and humans. This version is:

- **Reproducible, pure, and templatable**
- **Works with nix develop, user@machine, devshells, CI, and flake checks**
- **Correctly enables pre-commit as a flake check**
- **Avoids common errors with `config.pre-commit.check` (which is NOT a derivation)**
- **Uses the proper derivation: `config.pre-commit.settings.run`**

---

````markdown
# INSTRUCT: Enable pre-commit hooks with flake-parts and devShell (git-hooks.nix, pure, reproducible, with flake check)

To set up pre-commit hooks using [git-hooks.nix](https://github.com/cachix/git-hooks.nix) with [flake-parts](https://flake.parts/) in a **pure, reproducible, and templatable** way (per-system, with devShell, and with working `nix flake check`), follow these steps exactly:

---

## 1. Add Required Inputs

Add these to your `flake.nix`:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # or your desired channel
  flake-parts.url = "github:hercules-ci/flake-parts";
  git-hooks-nix.url = "github:cachix/git-hooks.nix";
  git-hooks-nix.inputs.nixpkgs.follows = "nixpkgs";
};
```
````

---

## 2. Import the git-hooks.nix flake-parts Module

In your `outputs`, make sure to import the module:

```nix
outputs = inputs@{ self, flake-parts, git-hooks-nix, ... }:
  flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [ inputs.git-hooks-nix.flakeModule ];
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
```

---

## 3. Configure Pre-commit Hooks (per system)

**Inside your `perSystem` block,** set hooks under `pre-commit.settings.hooks`:

```nix
perSystem = { config, pkgs, ... }: {
  pre-commit.settings.hooks = {
    alejandra.enable = true;
    deadnix.enable = true;
    statix.enable = true;
    prettier = {
      enable = true;
      types = [ "markdown" "yaml" "json" ];
    };
    custom-hook = {
      enable = true;
      name = "Custom script";
      entry = "./scripts/test-flake.sh";
      language = "script";
      pass_filenames = false;
    };
  };
```

---

## 4. Add a DevShell That Installs the Hooks

**Still inside `perSystem`,** add a devShell that runs the pre-commit installation script:

```nix
  devShells.default = pkgs.mkShell {
    packages = with pkgs; [
      alejandra deadnix statix nodePackages.prettier git
      # ...any other tools you want in your shell
    ];
    shellHook = ''
      ${config.pre-commit.installationScript}
      echo "Pre-commit hooks installed! Use 'pre-commit run --all-files' to check all files."
    '';
  };
};
```

---

## 5. Flake Checks for Pre-commit

> The git-hooks.nix flake-parts module automatically adds a per-system `checks.pre-commit` derivation for you (enabled by default).  
> **Do NOT manually set `checks.pre-commit` in your flake!**
>
> - `nix flake check` will automatically run your pre-commit hooks for each system you list in `systems`.
> - To disable this, set `pre-commit.check.enable = false;` in your `perSystem`.

---

## 6. Full Minimal Example

```nix
{
  description = "Example with pre-commit hooks in flake-parts and working flake check";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    git-hooks-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, flake-parts, git-hooks-nix, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.git-hooks-nix.flakeModule ];
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      perSystem = { config, pkgs, ... }: {
        pre-commit.settings.hooks = {
          alejandra.enable = true;
          deadnix.enable = true;
          statix.enable = true;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [ alejandra deadnix statix ];
          shellHook = ''
            ${config.pre-commit.installationScript}
            echo "Pre-commit hooks installed!"
          '';
        };

        # Do NOT set checks.pre-commit!
      };
    };
}
```

---

**Summary:**

- Use only `pre-commit.settings.hooks` in `perSystem` for flake-parts + git-hooks.nix.
- Use `${config.pre-commit.installationScript}` in your devShell's `shellHook`.
- **Do NOT manually set `checks.pre-commit`**—it is handled for you.
- This setup is pure, reproducible, and safe for templated sharing (`user@machine` and CI workflows).

---

**If you need to disable the check for a system:**

```nix
perSystem = { ... }: {
  pre-commit.check.enable = false;
  # ...rest as before
}
```

---
