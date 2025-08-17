{
  lib,
  config,
  username,
  pkgs,
  ...
}:
let
  cfg = config.sunshine;
in
{
  options = {
    sunshine = {
      enable = lib.mkEnableOption "Enable sunshine in NixOS";
    };
  };
  config = lib.mkIf cfg.enable {
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
    };
    home-manager.users.${username} = { };
  };
}
