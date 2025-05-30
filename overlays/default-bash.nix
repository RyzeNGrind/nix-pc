# overlays/default-bash.nix
_final: prev: {
  bash = prev.bashInteractive;
}
