# overlays/default-bash.nix
prev: {
  bash = prev.bashInteractive;
}