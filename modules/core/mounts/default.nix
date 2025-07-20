{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.mounts;
in
{
  options = {
    mounts = {
      enable = lib.mkEnableOption "Enable mounts in NixOS";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cifs-utils
      nfs-utils
    ];
    # fileSystems = builtins.listToAttrs (
    #   builtins.map
    #     (mount: {
    #       name = "/mnt/vault101/${mount}";
    #       value = {
    #         device = "192.168.1.2:/volume1/${mount}";
    #         fsType = "nfs";
    #         options = [
    #           "x-systemd.automount"
    #           "x-systemd.idle-timeout=600"
    #           "noauto"
    #           "noatime"
    #         ];
    #       };
    #     })
    #     [
    #       "data"
    #       "homes/lars"
    #       # "Downloads"
    #       # "Games"
    #       # "Life"
    #       # "Media"
    #       # "Miscellaneous"
    #       # "Photos"
    #       # "Projects"
    #     ]
    # );
    fileSystems."/mnt/vault101/data" = {
      device = "192.168.1.2:/volume1/data";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "x-systemd.idle-timeout=600"
        "noauto"
        "noatime"
      ];
    };
    fileSystems."/mnt/vault101/lars" = {
      device = "192.168.1.2:/volume1/homes/lars";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "x-systemd.idle-timeout=600"
        "noauto"
        "noatime"
      ];
    };
    services.rpcbind.enable = true;
  };
}
