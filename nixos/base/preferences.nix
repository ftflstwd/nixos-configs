{
  # Options only. Every file that defines `flake.nixosModules.base` is merged
  # together, so you can grow `base` by dropping more files in this directory.
  flake.nixosModules.base = {lib, ...}: {
    options.preferences = {
      user.name = lib.mkOption {
        type = lib.types.str;
        default = "ftflstwd";
        description = "Primary user login name.";
      };

      user.description = lib.mkOption {
        type = lib.types.str;
        default = "Daniel Poston";
        description = "Primary user's display name (GECOS).";
      };
    };
  };
}
