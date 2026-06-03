{self, ...}: {
  # Baseline user environment: the primary account, shell, sudo policy, and
  # broadly-useful CLI tooling. Pulls in the infra wrappers every host wants.
  flake.nixosModules.general = {
    pkgs,
    config,
    ...
  }: {
    imports = [
      self.nixosModules.extra_hjem
      self.nixosModules.extra_sops
      self.nixosModules.nix
      self.nixosModules.fish
    ];

    users.users.${config.preferences.user.name} = {
      isNormalUser = true;
      description = config.preferences.user.description;
      shell = pkgs.fish;
      extraGroups = ["networkmanager" "uucp" "wheel"];
      # Password is provided per-host via sops (see hosts/<host>/secrets.nix).
    };

    # fish itself is enabled and configured in fish.nix (imported above).
    security.sudo.wheelNeedsPassword = false;

    environment.systemPackages = with pkgs; [
      age # sops age-key tooling (age-keygen); pairs with sops below
      bat
      btop
      doggo
      eza
      fastfetch
      fd
      fzf
      ghostty
      git
      neovim
      nmap
      ripgrep
      sops # edit the encrypted secrets.yaml: `sops nixos/hosts/<host>/secrets.yaml`
      trippy
      witr
    ];
  };
}
