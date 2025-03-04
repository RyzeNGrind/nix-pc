# overlays/default-bash.nix
final: prev: {
  bash = prev.bashInteractive;
}