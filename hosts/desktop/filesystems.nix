{ lib, username, ... }:
{
  fileSystems."/" = {
    fsType = "tmpfs";
    options = [
      "defaults"
      "mode=755"
    ];
  };

  fileSystems."/boot" = {
    fsType = "vfat";
    options = [
      "fmask=0077"
      "umask=0077"
    ];
  };

  fileSystems."/home" = {
    fsType = "btrfs";
    options = [
      "compress=zstd:3"
      "subvol=home"
    ];
    neededForBoot = true;
  };

  fileSystems."/nix" = {
    fsType = "btrfs";
    options = [
      "compress=zstd:3"
      "subvol=nix"
    ];
  };

  fileSystems."/persist" = {
    neededForBoot = true;
    options = [
      "compress=zstd:3"
      "subvol=persist"
    ];
  };

  swapDevices = lib.mkForce [ ];

  fileSystems."/home/${username}/Games" = {
    depends = [ "/home" ];
    device = "/dev/disk/by-uuid/4361f6a9-6cc2-45c5-b347-9982a949b959";
    fsType = "btrfs";
    options = [
      "compress=zstd:3"
    ];
    neededForBoot = false;
  };
}
