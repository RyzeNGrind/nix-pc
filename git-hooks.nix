# ./git-hooks.nix
{
  alejandra = {
    enable = true;
  };
  deadnix = {
    enable = true;
  };
  statix = {
    enable = true;
  };
  prettier = {
    enable = true;
    types_or = ["markdown" "yaml" "json"];
  };
  nixos-config-tests = {
    enable = false;
    name = "NixOS Configuration Tests";
    entry = "";
    language = "script";
    pass_filenames = false;
  };
}
