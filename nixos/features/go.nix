{
  flake.nixosModules.go = {pkgs, ...}: {
    environment.systemPackages = [pkgs.go];
  };
}
