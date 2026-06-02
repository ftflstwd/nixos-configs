{
  flake.nixosModules.steam = {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    hardware.opengl.driSupport32Bit = true;
  };
}
