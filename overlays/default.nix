# overlays/default.nix
{nixpkgs-unstable, ...}: {
  # This imports your specific overlay file and assigns it to a key.
  # The key name 'default-bash' here is arbitrary, you'll refer to it
  # when applying the overlay.
  # Or, if you want this to be part of a 'default' overlay:
  default = import ./default-bash.nix; # Assuming default-bash.nix is your 'default' overlay
  unstable = _final: prev: {
    unstable = import nixpkgs-unstable {
      # 'nixpkgs-unstable' is an input to the flake
      inherit (prev) system;
      config.allowUnfree = true;
    };
  };

  # If you had another overlay, say 'my-custom-packages.nix':
  # custom-packages = final: prev: (import ./my-custom-packages.nix final prev);

  # Or, if default-bash.nix is the *only* overlay you want for a 'default' key:
  # default = import ./default-bash.nix;
}
