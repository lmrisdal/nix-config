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

  swapDevices = lib.mkForce [ ];

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

  fileSystems."/home/${username}/Games" = {
    # fileSystems."/mnt/Games" = {
    depends = [ "/home" ];
    device = "/dev/disk/by-id/nvme-eui.00000000000000000026b76870ed12c5-part2";
    fsType = "ntfs";
    options = [
      "uid=1000"
      "gid=100"
      "rw"
      "user"
      "exec"
      "umask=000"
    ];
    neededForBoot = false;
  };

  #   fileSystems."/mnt/gamedisk" = {
  #     # device = "/dev/nvme0n1p1";
  #     device = "/dev/disk/by-uuid/C05A10CA5A10BEDA";
  #     fsType = "ntfs";
  #     options = [ "rw" "exec" "relatime" "umask=000" ];
  #     neededForBoot = false;
  #   };

  fileSystems."/mnt/vault101" = {
    device = "//192.168.1.2/data";
    fsType = "cifs";
    options = [
      "rw"
      "uid=100000"
      "gid=110000"
      "dir_mode=0777"
      "file_mode=0777"
      "credentials=/home/${username}/.config/smb-secrets"
      "x-systemd.automount"
      "noauto"
    ];
    neededForBoot = false;
  };

  # fileSystems."/media/Vault101" = {
  #   device = "192.168.1.2:/data";
  #   fsType = "nfs";
  #   options = [
  #     "rw"
  #     "x-systemd.automount"
  #     "noauto"
  #   ];
  #   neededForBoot = false;
  # };
}
