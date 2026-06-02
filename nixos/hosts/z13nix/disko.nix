{
  # Declarative partition spec for z13nix. disko is now the source of truth for
  # this machine's disk: wiping + reinstalling reformats from exactly this.
  #
  #   * single disk, GPT
  #   * 1G EFI System Partition (vfat) -> /boot
  #   * swap partition (resume-capable)
  #   * btrfs filling the rest, top-level mounted at /, with `home` and `nix`
  #     subvolumes (matching your subvol=home / subvol=nix mounts)
  #
  # Read as both: the system's fileSystems (via the imported disko module) AND
  # the formatter target for the disko CLI (`--flake .#z13nix`).
  flake.diskoConfigurations.z13nix = {
    disko.devices = {
      disk.main = {
        # Micron MTFDKBK1T0QGN 1TB NVMe (nvme0n1). The mmcblk0 SD card is left
        # untouched. Avoid the "..._1" duplicate alias and the opaque eui. one.
        device = "/dev/disk/by-id/nvme-MTFDKBK1T0QGN-1BN1AABGA_2527518E6157";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            esp = {
              name = "ESP";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["fmask=0077" "dmask=0077"];
              };
            };

            swap = {
              # Sized for hibernate: the kernel sees ~48G (64G physical minus
              # the 16G iGPU UMA carveout, which is firmware-reserved and never
              # part of a hibernate image). Drop to ~16-32G if you don't use
              # suspend-to-disk and just want pressure relief.
              size = "48G";
              content = {
                type = "swap";
                resumeDevice = true;
              };
            };

            root = {
              name = "root";
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = ["-f"];

                # Top-level volume mounted at / (matches your current "/").
                mountpoint = "/";

                subvolumes = {
                  "home" = {
                    mountpoint = "/home";
                    mountOptions = ["subvol=home" "noatime"];
                  };
                  "nix" = {
                    mountpoint = "/nix";
                    mountOptions = ["subvol=nix" "noatime"];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
