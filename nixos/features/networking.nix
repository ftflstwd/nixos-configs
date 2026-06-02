{
  # NetworkManager. The hostname stays per-host in the host module.
  flake.nixosModules.networking = {
    networking.networkmanager.enable = true;
  };
}
