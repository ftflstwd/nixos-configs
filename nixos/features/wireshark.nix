{
  # Uses the NixOS program module (not a bare package) so dumpcap gets the
  # right capabilities and members of the `wireshark` group can capture without
  # root. The primary user is added to that group here.
  flake.nixosModules.wireshark = {
    pkgs,
    config,
    ...
  }: {
    programs.wireshark = {
      enable = true;
      # Full Qt GUI. The module default is pkgs.wireshark-cli (tshark/dumpcap
      # only) — swap to that if you don't want the GUI.
      package = pkgs.wireshark;
    };

    users.users.${config.preferences.user.name}.extraGroups = ["wireshark"];
  };
}
