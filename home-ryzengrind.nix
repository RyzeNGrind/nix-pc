{ config, pkgs, lib, inputs, ... }: # inputs is available from specialArgs in flake.nix -> configuration.nix -> here

let
  # Define the 1Password item path for your nix-ws SSH key.
  # Replace <VAULT_NAME> and <ITEM_NAME_FOR_NIX_WS_KEY> with your actual values.
  # Example: "op://Private/Nix WS SSH Key/private key"
  nixWsSshPrivateKeyPath = "op://ygwk7irr6e2agp35fqbv54emcq/minj427njw4gall6in2vittq4q/private_key";
  nixWsSshPublicKeyPath = "op://ygwk7irr6e2agp35fqbv54emcq/minj427njw4gall6in2vittq4q/public_key"; # Or the field where the public key is stored

  # Hostname/IP for nix-ws
  nixWsHostIdentifier = "nix-ws"; # Used for SSH config alias
  nixWsHostname = "192.168.1.3";
  nixWsUser = "ryzengrind";

in
{
  imports = [
    inputs.opnix.homeManagerModules.default # Import opnix Home Manager module
  ];

  # Basic Home Manager settings
  home.username = "ryzengrind";
  home.homeDirectory = "/home/ryzengrind";
  home.stateVersion = "24.11"; # Or your preferred state version

  # Install 1Password CLI and GUI (GUI might provide the agent)
  home.packages = with pkgs; [
    onepassword-cli
    onepassword # For the desktop app, which provides the SSH agent
    # You might only need onepassword-cli if you configure opnix to use the CLI's agent capabilities
    # or if the main 'onepassword' package sets up the agent correctly.
  ];

  # Configure opnix for 1Password integration
  programs.opnix = {
    enable = true;
    # The package can be inferred if `pkgs.onepassword-cli` is in home.packages
    # package = pkgs.onepassword-cli; 
    # CLI path can also be often inferred
    # cliPath = "${pkgs.onepassword-cli}/bin/op";
  };

  # Configure 1Password CLI settings (via opnix or directly if preferred)
  # This ensures `op` commands can work.
  # `programs.op` might be an alternative if opnix doesn't cover all CLI setup needs.

  # SSH Client Configuration
  programs.ssh = {
    enable = true;
    # Let 1Password manage the SSH agent.
    # Ensure "Developer -> SSH Agent" is enabled in your 1Password Desktop App settings.
    # And ensure "Integrate with 1Password CLI" is also enabled.
    startAgent = false; # 1Password provides its own agent

    # Define the SSH identity for nix-ws using the key from 1Password
    identities."${nixWsHostIdentifier}" = {
      # This tells opnix to fetch the secret content from 1Password
      text = config.op.secrets."${nixWsSshPrivateKeyPath}".value;
      # You might also need to specify the public key if it's not automatically derived
      # or if your private key file doesn't embed it.
      # publicKey = config.op.secrets."${nixWsSshPublicKeyPath}".value;
    };

    # Configure SSH to use this identity for the nix-ws host
    matchBlocks."${nixWsHostIdentifier}" = {
      user = nixWsUser;
      hostname = nixWsHostname;
      # This will point to the path where Home Manager places the identity file
      # (e.g., ~/.ssh/identity_nix-ws or similar, derived from identities."nix-ws")
      identityFile = "~/.ssh/identity_${nixWsHostIdentifier}";
      # You might want to add other options like:
      # visualHostKey = "yes";
      # preferredAuthentications = "publickey";
    };

    # Optional: Add all keys from 1Password marked with `ssh-add` tag to the agent
    # This requires 1Password 8.10.0 or newer and `programs.op.enableSshAgent = true;`
    # addKeysToAgent = "yes"; # This is a global ssh_config option, might be better handled by 1P agent settings
  };
  
  # If you are using 1Password's SSH agent directly (recommended)
  # Ensure it's configured in 1Password Desktop App:
  # Settings -> Developer -> SSH Agent (enable it)
  # Also, ensure "Integrate with 1Password CLI" is enabled.
  # The `SSH_AUTH_SOCK` environment variable should then point to 1Password's agent socket.
  # Home Manager or your shell init might need to set this if not done automatically by 1P.
  # For Fish shell, you might need something like this in your fish config:
  # set -x SSH_AUTH_SOCK $HOME/.1password/agent.sock (check actual path)

  # Enable direnv for project-specific environments
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Allow Home Manager to manage itself
  programs.home-manager.enable = true;
}