{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.z13nix = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.hostZ13nix
    ];
  };

  # Host module: machine-specific config only. Everything reusable lives in
  # nixos/features/* and is selected from the imports list below.
  flake.nixosModules.hostZ13nix = {pkgs, ...}: {
    imports = [
      self.nixosModules.base
      self.nixosModules.general

      # desktop + system features
      self.nixosModules.gnome
      self.nixosModules.networking
      self.nixosModules.wifi
      self.nixosModules.pipewire
      self.nixosModules.printing
      self.nixosModules.locale

      # shell experience
      self.nixosModules.direnv
      self.nixosModules.starship
      self.nixosModules.git

      # security / hardware
      self.nixosModules.yubikey
      self.nixosModules.ssh

      # apps (one module per program)
      self.nixosModules.chromium
      self.nixosModules.foliate
      self.nixosModules.obsidian
      self.nixosModules.remmina
      self.nixosModules.vlc
      self.nixosModules.ffmpeg
      self.nixosModules.cliamp
      self.nixosModules.yt-dlp
      self.nixosModules.go
      self.nixosModules.python3
      self.nixosModules.opencode
      self.nixosModules.wireshark
      self.nixosModules.steam

      # disko owns this machine's disk. The module provides the fileSystems +
      # swap; the spec in ./disko.nix is the formatter target. Set the device
      # in disko.nix before rebuilding.
      self.nixosModules.extra_disko
      self.diskoConfigurations.z13nix
    ];

    # ── machine-specific ───────────────────────────────────────────────────
    networking.hostName = "z13nix";

    # Home WiFi SSID for the `wifi` feature. The PSK is a sops secret
    # (wifi-env) wired in secrets.nix — only the (non-secret) SSID lives here.
    preferences.wifi.ssid = "You Kids Get Off My LAN";

    # ASUS laptop controls. Lives here (not a feature) since this is the only
    # ASUS device; promote it to nixos/features/asusd.nix if that changes.
    services.asusd.enable = true;

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelPackages = pkgs.linuxPackages_latest;

    system.stateVersion = "26.05";
  };
}
