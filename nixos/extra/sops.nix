{inputs, ...}: {
  # Imports sops-nix and points it at the age private key used for decryption.
  # No secrets are defined here, so this module is harmless on its own — hosts
  # declare their own `sops.defaultSopsFile` and `sops.secrets.*`.
  flake.nixosModules.extra_sops = {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    # The age private key that unlocks this host's secrets. It is the root of
    # trust and MUST NOT live in the repo — provision it out-of-band per host
    # (see README "secrets"). /var/lib is on the persistent btrfs root, so it
    # survives reboots; on a disko wipe you restore it from your own backup.
    sops.age.keyFile = "/var/lib/sops-nix/key.txt";

    # We provision the key ourselves; don't let sops-nix generate one.
    sops.age.generateKey = false;
  };
}
