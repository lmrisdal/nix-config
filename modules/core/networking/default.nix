{
  lib,
  config,
  ...
}:
let
  cfg = config.networking;
in
{
  options = {
    networking = {
      enable = lib.mkEnableOption "Enable networking in NixOS & home-manager";
    };
  };
  config = lib.mkIf cfg.enable {
    networking = {
      networkmanager = {
        enable = true;
        wifi.powersave = false;
      };
      useDHCP = lib.mkDefault true;
      wireguard.enable = true;
    };
    boot.kernel.sysctl."net.ipv4.tcp_mtu_probing" = true;
  };
}
