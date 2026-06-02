{
  # Declarative home WiFi via NetworkManager's ensureProfiles. The SSID is not
  # secret (it's broadcast), so it's a `preferences.wifi.ssid` option set per
  # host. The PSK IS secret: it never appears here or in the nix store —
  # instead `environmentFiles` reads it at activation from a sops-decrypted
  # file and substitutes the $HOME_WIFI_PSK placeholder below.
  #
  # DEPENDS ON: a sops secret named `wifi-env` (declared in the host's
  # secrets.nix, decrypted to a file whose contents are the single line
  #   HOME_WIFI_PSK=your-wifi-password
  # ). general → extra_sops provides the sops machinery; secrets.nix sets the
  # defaultSopsFile this secret is read from.
  #
  # Import via `self.nixosModules.wifi` and set `preferences.wifi.ssid`.
  flake.nixosModules.wifi = {
    config,
    lib,
    ...
  }: {
    options.preferences.wifi.ssid = lib.mkOption {
      type = lib.types.str;
      description = "SSID of the home wireless network to auto-configure.";
    };

    config = {
      networking.networkmanager.ensureProfiles = {
        # The PSK is injected from this sops-decrypted env file at activation;
        # the file holds `HOME_WIFI_PSK=...`. Keep the secret name in sync with
        # secrets.nix.
        environmentFiles = [config.sops.secrets.wifi-env.path];

        profiles.home = {
          connection = {
            id = "home";
            type = "wifi";
          };
          wifi = {
            ssid = config.preferences.wifi.ssid;
            mode = "infrastructure";
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "$HOME_WIFI_PSK"; # substituted from environmentFiles
          };
          ipv4.method = "auto";
          ipv6.method = "auto";
        };
      };
    };
  };
}
