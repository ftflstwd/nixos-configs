{inputs, ...}: {
  # Imports the disko NixOS module once. Each host adds its own partition spec
  # via `self.diskoConfigurations.<host>` alongside this in its imports list.
  flake.nixosModules.extra_disko = {
    imports = [
      inputs.disko.nixosModules.disko
    ];
  };
}
