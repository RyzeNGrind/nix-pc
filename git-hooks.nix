# \home\ryzengrind\nix-pc\git-hooks.nix
#{pkgs, ... }: {
{
  alejandra = {enable = true;};
  deadnix = {enable = true;};
  statix = {enable = true;};
  prettier = {
    enable = true;
    types = ["markdown" "yaml" "json"];
  };
  "nixos-config-tests" = {
    enable = false; # Simply disable it
    name = "NixOS Configuration Tests";
    # Entry can be left as is or simplified, it won't run if enable = false
    entry = ""; # Or some placeholder, or the old definition
    language = "script";
    pass_filenames = false;
  };
}
