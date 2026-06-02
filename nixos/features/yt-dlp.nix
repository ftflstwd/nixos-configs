{
  flake.nixosModules.yt-dlp = {pkgs, ...}: {
    environment.systemPackages = [pkgs.yt-dlp];
  };
}
