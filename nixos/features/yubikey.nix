{
  # YubiKey support. Two layers:
  #
  #   1. Foundational hardware support (always on when this module is imported):
  #      - pcscd: the smart-card daemon. Required for the YubiKey's CCID
  #        interfaces — OpenPGP, PIV, and OATH (TOTP/HOTP) via ykman / the
  #        Authenticator app.
  #      - udev rules (yubikey-personalization) so the device is accessible to
  #        the logged-in user without root.
  #      - CLI tooling (ykman, fido2-token) and the libfido2 udev rules.
  #      - gnupg agent (for OpenPGP). Its SSH-agent support is OPT-IN
  #        (`preferences.yubikey.gpgSshAgent`, default off) and intentionally so:
  #        it hijacks SSH_AUTH_SOCK, which BREAKS FIDO2 (`-sk`) SSH keys. Leave
  #        it off unless you are using the OpenPGP-smartcard SSH path instead.
  #
  #      FIDO2 SSH keys (ssh-keygen -t ed25519-sk) use the USB-HID FIDO
  #      interface and need NEITHER pcscd NOR gpg-agent — just openssh (built
  #      with security-key support, as nixpkgs is) and the libfido2 udev rules.
  #
  #   2. PAM U2F login/sudo (OPT-IN, default off). Using the key as a second
  #      factor for login is gated behind `preferences.yubikey.enableU2fLogin`
  #      because enabling it before registering a key can LOCK YOU OUT. See the
  #      warning on that option below.
  #
  # Import via `self.nixosModules.yubikey`.
  flake.nixosModules.yubikey = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.preferences.yubikey;
  in {
    options.preferences.yubikey.gpgSshAgent = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Have gpg-agent provide the SSH auth socket, so the YubiKey's OpenPGP
        authentication subkey is used as your SSH key (the GPG-smartcard path).

        Leave this OFF if you use FIDO2 (`ssh-keygen -t ed25519-sk`) keys:
        gpg-agent claims SSH_AUTH_SOCK and cannot serve FIDO security-key files,
        which breaks `ssh-add` of those keys.
      '';
    };

    options.preferences.yubikey.enableU2fLogin = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Use the YubiKey as a U2F/FIDO2 factor for login, GDM, and sudo.

        WARNING: enable this only AFTER registering at least one key, or you can
        lock yourself out. With your key plugged in, run:

            mkdir -p ~/.config/Yubico
            pamu2fcfg > ~/.config/Yubico/u2f_keys      # touch the key when it blinks
            # add a second key as backup:
            pamu2fcfg >> ~/.config/Yubico/u2f_keys

        `cue` is set, so PAM prompts you to touch the key. Note: sudo on this
        system is already passwordless (security.sudo.wheelNeedsPassword =
        false), so the sudo factor only takes effect if that changes.
      '';
    };

    config = lib.mkMerge [
      {
        # ── foundational hardware support ──────────────────────────────────
        services.pcscd.enable = true;

        # udev rules for device access: yubikey-personalization covers the
        # smartcard/OTP interfaces, libfido2 covers the FIDO2/U2F HID interface
        # used by `-sk` SSH keys.
        services.udev.packages = [
          pkgs.yubikey-personalization
          pkgs.libfido2
        ];

        environment.systemPackages = with pkgs; [
          yubikey-manager # `ykman`: configure OpenPGP/PIV/OATH/FIDO applets, set FIDO2 PIN
          yubikey-personalization # `ykpersonalize`, `ykinfo`
          libfido2 # `fido2-token`: inspect/manage resident FIDO2 credentials
          # Optional GUI apps you can add if you want them:
          #   yubico-authenticator   # OATH TOTP/HOTP desktop app
          #   yubikey-manager-qt     # ykman GUI
        ];

        # gpg-agent runs for OpenPGP use. SSH support is gated (see option
        # above) — off by default so FIDO2 `-sk` SSH keys work.
        programs.gnupg.agent = {
          enable = true;
          enableSSHSupport = cfg.gpgSshAgent;
        };
      }

      (lib.mkIf cfg.enableU2fLogin {
        # ── opt-in U2F/FIDO2 login factor ──────────────────────────────────
        security.pam.u2f = {
          enable = true;
          settings.cue = true; # prompt: "touch your security key"
        };

        # Opt the relevant services into the U2F factor.
        security.pam.services.login.u2fAuth = true;
        security.pam.services.gdm.u2fAuth = true;
        security.pam.services.sudo.u2fAuth = true;
      })
    ];
  };
}
