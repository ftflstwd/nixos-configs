{
  # starship prompt. The NixOS module appends the prompt init to fish (and
  # bash/zsh) automatically when those shells are enabled, so there is no
  # manual `starship init fish | source` line to add.
  #
  # starship's defaults already surface directory, git branch/status,
  # nix-shell, and language versions (Go, Python, …) contextually, so this
  # keeps configuration minimal.
  flake.nixosModules.starship = {
    programs.starship = {
      enable = true;
      settings = {
        # Nix evaluations can be slow; the 500 ms default occasionally makes
        # modules (git, nix_shell) time out and silently drop. Bump it.
        command_timeout = 1000;
        add_newline = false;
      };
    };
  };
}
