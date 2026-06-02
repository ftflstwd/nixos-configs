{
  flake.nixosModules.foliate = {pkgs, ...}: {
    environment.systemPackages = [pkgs.foliate];
  };
}
