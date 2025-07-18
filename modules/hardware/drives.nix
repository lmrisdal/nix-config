{ config, pkgs, ... }:
{
  # Mount points

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
}
