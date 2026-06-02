# ACTIVE: imported by importTree, wires the user password from sops.
#
# `neededForUsers = true` decrypts this secret early enough that it is available
# when the user account is created — required for a password on first boot.
# Decryption uses the host age key at /var/lib/sops-nix/key.txt (see
# nixos/extra/sops.nix). secrets.yaml is encrypted to the admin + host keys in
# .sops.yaml; edit it with `sops nixos/hosts/z13nix/secrets.yaml`.
{
  flake.nixosModules.hostZ13nix = {config, ...}: {
    sops.defaultSopsFile = ./secrets.yaml;

    sops.secrets."ftflstwd-password" = {
      neededForUsers = true;
    };

    # WiFi PSK for the `wifi` feature module. Decrypted at activation (no
    # neededForUsers — it isn't needed during user creation). The secret's
    # value is a full env line: `HOME_WIFI_PSK=your-wifi-password`, which
    # NetworkManager's ensureProfiles reads via environmentFiles. Add it with
    #   sops nixos/hosts/z13nix/secrets.yaml
    # under the key `wifi-env`.
    sops.secrets.wifi-env = {};

    users.users.${config.preferences.user.name}.hashedPasswordFile =
      config.sops.secrets."ftflstwd-password".path;
  };
}
