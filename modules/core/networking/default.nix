{
  lib,
  config,
  pkgs,
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
    environment.systemPackages = with pkgs; [
      iwd
      networkmanagerapplet
    ];
    hardware.wirelessRegulatoryDatabase = true;
    sops.secrets."wifi/home_ultra/ssid" = { };
    sops.secrets."wifi/home_ultra/psk" = { };
    sops.secrets."wifi/home/ssid" = { };
    sops.secrets."wifi/home/psk" = { };
    sops.secrets."wifi/phone/ssid" = { };
    sops.secrets."wifi/phone/psk" = { };
    networking = {
      networkmanager = {
        enable = true;
        wifi.powersave = false;
        wifi.backend = "iwd";
        ensureProfiles = {
          environmentFiles = [
            config.sops.secrets."wifi/home_ultra/ssid".path
            config.sops.secrets."wifi/home_ultra/psk".path
            config.sops.secrets."wifi/home/ssid".path
            config.sops.secrets."wifi/home/psk".path
            config.sops.secrets."wifi/phone/ssid".path
            config.sops.secrets."wifi/phone/psk".path
          ];
          profiles = {
            "home-ultra" = {
              connection.id = "Home (6ghz)";
              connection.type = "wifi";
              connection.autoconnect = true;
              connection.autoconnect-priority = 1;
              wifi.ssid = "$HOME_ULTRA_SSID";
              wifi-security = {
                auth-alg = "open";
                key-mgmt = "wpa-psk";
                psk = "$HOME_ULTRA_PSK";
              };
              ipv4.method = "manual";
              ipv4.addresses = "192.168.1.3/24";
              ipv4.gateway = "192.168.1.1";
              ipv4.dns = "192.168.1.1";
              ipv6 = {
                method = "auto";
                addr-gen-mode = "stable-privacy";
              };
            };
            "home" = {
              connection.id = "Home";
              connection.type = "wifi";
              connection.autoconnect = false;
              wifi.ssid = "$HOME_SSID";
              wifi-security = {
                auth-alg = "open";
                key-mgmt = "wpa-psk";
                psk = "$HOME_PSK";
              };
              ipv4.method = "manual";
              ipv4.addresses = "192.168.1.3/24";
              ipv4.gateway = "192.168.1.1";
              ipv4.dns = "192.168.1.1";
            };
            "phone" = {
              connection.id = "iPhone Hotspot";
              connection.type = "wifi";
              connection.metered = "yes";
              connection.autoconnect = false;
              wifi.ssid = "$PHONE_SSID";
              wifi-security = {
                auth-alg = "open";
                key-mgmt = "wpa-psk";
                psk = "$PHONE_PSK";
              };
            };
          };
        };
      };
      useDHCP = lib.mkDefault true;
      wireguard.enable = true;
    };
    boot.kernel.sysctl."net.ipv4.tcp_mtu_probing" = true;
    boot.extraModprobeConfig = ''
      options iwlwifi power_save=0
      options iwlmvm power_scheme=1 
      options cfg80211 ieee80211_regdom="NO"
    '';
  };
}
