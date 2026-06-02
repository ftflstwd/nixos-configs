{
  # Declarative git identity + defaults for the primary user. git itself is
  # already installed in general.nix systemPackages; this module only supplies
  # the user-level configuration.
  #
  # We don't use home-manager's `programs.git` here (this repo uses hjem, not
  # home-manager, for user files), so the config is written directly to the
  # XDG location `~/.config/git/config` via hjem. git reads that file for every
  # repo owned by the user.
  #
  # The git user.name reuses `preferences.user.name` (the login handle) so there
  # is a single source of truth; email and the default branch are their own
  # preferences with sensible defaults that a host may override.
  #
  # Import via `self.nixosModules.git`.
  flake.nixosModules.git = {
    config,
    lib,
    ...
  }: let
    user = config.preferences.user.name;
  in {
    options.preferences.git = {
      userEmail = lib.mkOption {
        type = lib.types.str;
        default = "code@faithfulsteward.tech";
        description = "Email recorded in git commits (user.email).";
      };

      defaultBranch = lib.mkOption {
        type = lib.types.str;
        default = "main";
        description = "Branch name git uses when initializing a new repo (init.defaultBranch).";
      };
    };

    config.hjem.users.${user}.files.".config/git/config".text = ''
      [user]
      	name = ${user}
      	email = ${config.preferences.git.userEmail}
      [init]
      	defaultBranch = ${config.preferences.git.defaultBranch}
    '';
  };
}
