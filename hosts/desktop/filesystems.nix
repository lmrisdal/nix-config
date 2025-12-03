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
}
