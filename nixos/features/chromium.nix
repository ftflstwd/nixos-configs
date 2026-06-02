{
  flake.nixosModules.chromium = {pkgs, ...}: {
    # NOTE: programs.chromium ONLY writes managed-policy files (forced
    # extensions, etc.) to /etc/chromium/policies — it does NOT install the
    # browser. The package must be added separately (below). Without it the
    # browser only appears to exist while an older generation still references
    # it, and disappears as soon as GC prunes that generation.
    programs.chromium = {
      enable = true;

      # Force-installed from the Chrome Web Store by extension ID. These are
      # pinned by policy: the user can't disable/remove them in-browser, and
      # the binaries are fetched (and auto-updated) from the store at runtime
      # rather than pinned in the nix store. First install needs network.
      extensions = [
        "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
        "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
      ];
    };

    # Actually install the browser system-wide. (programs.chromium above only
    # configures policy; this is what puts `chromium` on PATH.)
    environment.systemPackages = [pkgs.chromium];
  };
}
