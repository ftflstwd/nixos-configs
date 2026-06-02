{
  # direnv with nix-direnv: per-directory environments via `.envrc`, with
  # nix-direnv caching `use flake` / `nix-shell` so re-entering a project dir
  # is instant instead of re-evaluating every time.
  #
  # The NixOS module auto-hooks fish (and bash/zsh) when those shells are
  # enabled, so no manual `direnv hook fish | source` line is required.
  flake.nixosModules.direnv = {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # Quiet direnv's "loading…" status lines on cd, without depending on any
    # module-specific option. Empty log format = no chatter.
    environment.variables.DIRENV_LOG_FORMAT = "";
  };
}
