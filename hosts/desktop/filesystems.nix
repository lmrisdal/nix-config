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
      "compress=zstd:1"
      "subvol=home"
    ];
  };

  fileSystems."/nix" = {
    fsType = "btrfs";
    options = [
      "compress=zstd:1"
      "subvol=nix"
    ];
  };

  fileSystems."/persist" = {
    neededForBoot = true;
    options = [
      "compress=zstd:1"
      "subvol=persist"
    ];
  };

  #   fileSystems."/home/${username}/Games" = {
  #     depends = [ "/home" ];
  #     device = "/dev/disk/by-id/id";
  #     fsType = "btrfs";
  #     options = [
  #       "compress=zstd:1"
  #     ];
  #   };

  #   fileSystems."/home/${username}/.local/share/games" = {
  #     depends = [ "/home" ];
  #     device = "/dev/disk/by-id/id";
  #     fsType = "btrfs";
  #     options = [
  #       "compress=zstd:1"
  #     ];
  #   };

  #   fileSystems."/mnt/windows" = {
  #     device = "/dev/disk/by-id/nvme-WDS250G2X0C-00L350_182012421668_1-part3";
  #     fsType = "ntfs";
  #     options = [
  #       "uid=1000"
  #       "gid=1000"
  #       "rw"
  #       "user"
  #       "exec"
  #       "umask=000"
  #     ];
  #   };

  #   fileSystems."/mnt/steamlibrary" = {
  #     # device = "/dev/nvme1n1p2";
  #     device = "/dev/disk/by-uuid/4EF28D75F28D6257";
  #     fsType = "ntfs";
  #     options = [ "rw" "exec" "relatime" "umask=000" ];
  #     neededForBoot = false;
  #   };
  #
  #   fileSystems."/mnt/gamedisk" = {
  #     # device = "/dev/nvme0n1p1";
  #     device = "/dev/disk/by-uuid/C05A10CA5A10BEDA";
  #     fsType = "ntfs";
  #     options = [ "rw" "exec" "relatime" "umask=000" ];
  #     neededForBoot = false;
  #   };

  # fileSystems."/mnt/vault101" = {
  #   device = "//192.168.1.2/data";
  #   fsType = "cifs";
  #   options = [
  #     "rw"
  #     "username=INSERT_USERNAME_HERE"
  #     "password=INSERT_PASSWORD_HERE"
  #     "x-systemd.automount"
  #     "noauto"
  #   ];
  #   neededForBoot = false;
  # };

  # fileSystems."/" = {
  #   device = "/dev/disk/by-uuid/57cc3a36-e0f8-414e-b40a-d1424de35b01";
  #   fsType = "btrfs";
  #   options = [ "subvol=@" ];
  # };

  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-uuid/A22A-187B";
  #   fsType = "vfat";
  #   options = [
  #     "fmask=0077"
  #     "dmask=0077"
  #   ];
  # };
  # Disable swap
  swapDevices = lib.mkForce [ ];
}
