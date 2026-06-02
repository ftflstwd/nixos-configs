{
  # GNOME desktop on X11 with GDM. Import via `self.nixosModules.gnome`.
  flake.nixosModules.gnome = {
    services.xserver.enable = true;
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };
  };
}
