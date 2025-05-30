{pkgs, ...}: {
  home = {
    username = "ryzengrind";
    homeDirectory = "/home/ryzengrind";
    stateVersion = "25.05"; # Or your current HM release version

    # You can also put home.packages here if you prefer
    # packages = with pkgs; [ ... ];
  };

  programs = {
    fish = {
      enable = true;
      interactiveShellInit = ''
        # Manual starship init for fish
        ${pkgs.starship}/bin/starship init fish | source
      '';
    };

    bash = {
      enable = true;
      # ... other bash settings
    };

    starship = {
      enable = true;
      # ... starship settings
    };
  };

  # If you have home.packages, it can stay separate or be moved into the main home attribute set
  # For example:
  # home.packages = with pkgs; [
  #   neovim
  # ];
  # Or inside the main home block:
  # home = {
  #   ...
  #   packages = with pkgs; [ neovim ];
  # };
}
