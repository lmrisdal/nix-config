{
  lib,
  config,
  username,
  pkgs,
  ...
}:
let
  cfg = config.vesktop;
in
{
  options = {
    vesktop = {
      enable = lib.mkEnableOption "Enable vesktop (Disord client) in NixOS & home-manager";
    };
  };
  config = lib.mkIf cfg.enable {
    home-manager.users.${username} = {
      programs.vesktop.enable = true;
      programs.vesktop.settings = {
        hardwareAcceleration = true;
        transparencyOption = "acrylic";
        splashTheming = true;
        minimizeToTray = true;
        tray = true;
        arRPC = true;
        appBadge = true;
        discordBranch = "canary";
      };
    };
  };
}
