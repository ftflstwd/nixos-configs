{
  flake.nixosModules.python3 = {pkgs, ...}: {
    environment.systemPackages = [pkgs.python3];
  };
}
