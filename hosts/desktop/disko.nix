{
  disks ? [ "/dev/disk/by-id/ata-SanDisk_SDSSDA960G_173337445106" ],
  ...
}:
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = builtins.elemAt disks 0;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            type = "EF00";
            priority = 1;
            size = "1024M";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "defaults"
                "umask=0077"
              ];
            };
          };
          # luks = {
          #   size = "100%";
          #   content = {
          #     type = "luks";
          #     name = "crypted";
          #     settings = {
          #       allowDiscards = true;
          #     };
          #     content = {
          #       type = "btrfs";
          #       extraArgs = [ "-f" ];
          #       subvolumes = {
          #         "/home" = {
          #           mountOptions = [
          #             "compress=zstd"
          #             "noatime"
          #           ];
          #           mountpoint = "/home";
          #         };
          #         "/nix" = {
          #           mountOptions = [
          #             "compress=zstd"
          #             "noatime"
          #           ];
          #           mountpoint = "/nix";
          #         };
          #         "/persist" = {
          #           mountOptions = [ "compress=zstd" ];
          #           mountpoint = "/persist";
          #         };
          #       };
          #     };
          #   };
          # };
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "/home" = {
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                  mountpoint = "/home";
                };
                "/nix" = {
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                  mountpoint = "/nix";
                };
                "/persist" = {
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                  mountpoint = "/persist";
                };
              };
            };
          };
        };
      };
    };
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [
          "mode=755"
          "size=1G"
        ];
      };
    };
  };
}
