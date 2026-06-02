{
  # Nix daemon settings.
  flake.nixosModules.nix = {
    nix.settings.experimental-features = ["nix-command" "flakes"];
    nixpkgs.config.allowUnfree = true;

    # Automatic garbage collection: prune generations older than 7 days, then
    # collect the now-unreferenced store paths. `--delete-older-than 7d` acts on
    # every profile under /nix/var/nix/profiles — including the NixOS system
    # profile — so boot generations older than a week are dropped (they fully
    # clear from the boot menu on the next rebuild, which reinstalls the loader).
    #
    # Runs daily so the 7-day window stays tight; `persistent` makes a run that
    # was missed while the machine was off fire on the next boot instead.
    nix.gc = {
      automatic = true;
      dates = "daily";
      persistent = true;
      options = "--delete-older-than 7d";
    };
  };
}
