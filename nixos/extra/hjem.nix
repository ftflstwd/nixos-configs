{inputs, ...}: {
  flake.nixosModules.extra_hjem = {config, ...}: let
    user = config.preferences.user.name;
  in {
    imports = [
      inputs.hjem.nixosModules.default
    ];

    config = {
      hjem = {
        # clobberByDefault lets hjem overwrite files it manages. Files you have
        # not declared are left untouched, so this is safe with an empty config.
        clobberByDefault = true;

        users.${user} = {
          enable = true;
          user = user;
          directory = "/home/${user}";

          # Declare dotfiles here as you migrate them, e.g.:
          #
          #   files.".config/ghostty/config".text = ''
          #     theme = catppuccin-mocha
          #   '';
          #
          #   files.".config/foo/bar.conf".source = ./dotfiles/bar.conf;
        };
      };

      # NOTE: recent hjem revisions may require choosing a linker, e.g.
      #   hjem.linker = inputs.hjem.packages.${pkgs.system}.smfh;
      # If `nixos-rebuild` complains about a missing linker, add that line.
    };
  };
}
