{
  flake.nixosModules.cliamp = {pkgs, ...}: {
    environment.systemPackages = [pkgs.cliamp];
  };
}
