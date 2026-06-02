{
  # Declarative ~/.ssh contents for the primary user, deployed via hjem:
  #   - ~/.ssh/config        (from ./ssh/config — blank scaffold for now)
  #   - ~/.ssh/<NAME>.pub    (every *.pub in ./ssh/keys/ — safe to publish)
  #   - ~/.ssh/<NAME>        (its FIDO2 private handle stub, if present; gated)
  #
  # Keys are AUTO-DISCOVERED from nixos/features/ssh/keys/: every NAME.pub there
  # is deployed, plus its matching stub NAME when that file also exists. So to
  # add a key you just drop NAME and NAME.pub into that directory and `git add`
  # them (flakes ignore untracked files) — no list to maintain.
  #
  # The FIDO2 `-sk` stub is NOT a real private key: the secret lives on the
  # YubiKey and never leaves it, so the stub is useless without the physical
  # key and is safe to commit. It is, however, deployed from the world-readable
  # nix store; see `deployPrivateStubs`.
  #
  # Import via `self.nixosModules.ssh`.
  flake.nixosModules.ssh = {
    config,
    lib,
    ...
  }: let
    user = config.preferences.user.name;
    cfg = config.preferences.ssh;

    keyDir = ./ssh/keys;

    # Base names = every *.pub in keyDir with the suffix stripped.
    pubNames = lib.filter (n: lib.hasSuffix ".pub" n) (lib.attrNames (builtins.readDir keyDir));
    baseNames = map (lib.removeSuffix ".pub") pubNames;

    # For each base name: deploy the .pub, and the private stub too when it
    # exists on disk and deployPrivateStubs is on.
    keyFiles =
      lib.foldl' (
        acc: base:
          acc
          // {
            ".ssh/${base}.pub".source = keyDir + "/${base}.pub";
          }
          // lib.optionalAttrs (cfg.deployPrivateStubs && builtins.pathExists (keyDir + "/${base}")) {
            ".ssh/${base}".source = keyDir + "/${base}";
          }
      ) {}
      baseNames;
  in {
    options.preferences.ssh.deployPrivateStubs = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Also deploy each private handle stub (NAME), not just NAME.pub.

        The stub is hardware-bound and useless without the YubiKey, so it is
        safe to commit — but it is deployed from the world-readable nix store,
        which also clobbers any existing 0600 copy in ~/.ssh. If ssh then
        refuses it ("UNPROTECTED PRIVATE KEY FILE ... too open"), set this to
        false: the committed stubs stay in the repo as a backup, and you
        recreate them locally per machine with `ssh-keygen -K` (correct 0600).
      '';
    };

    config.hjem.users.${user}.files =
      keyFiles
      // {
        ".ssh/config".source = ./ssh/config;
      };
  };
}
