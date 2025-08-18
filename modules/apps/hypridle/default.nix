{
  lib,
  config,
  pkgs,
  username,
  fullname,
  ...
}:
let
  cfg = config.hypridle;
in
{
  options = {
    hypridle = {
      enable = lib.mkEnableOption "Enable HyprIdle in home-manager";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      hypridle
    ];
    home-manager.users.${username} =
      { config, pkgs, ... }:
      {
        services.hypridle = {
          enable = true;
          settings = {
            general = {
              after_sleep_cmd = "playerctl stop; hyprctl dispatch dpms on";
              ignore_dbus_inhibit = false;
              lock_cmd = "hyprlock";
              on_lock_cmd = "playerctl stop";
            };

            listener = [
              {
                timeout = 900;
                on-timeout = "hyprlock";
              }
              {
                timeout = 1200;
                on-timeout = "hyprctl dispatch dpms off";
                on-resume = "hyprctl dispatch dpms on";
              }
            ];
          };
        };
      };
  };
}
