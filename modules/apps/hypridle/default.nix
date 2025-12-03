{
  lib,
  config,
  pkgs,
  username,
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
              lock_cmd = "pidof hyprlock || hyprlock";
              on_lock_cmd = "playerctl stop";
            };

            listener = [
              # {
              #   timeout = 300;
              #   on-timeout = "loginctl lock-session";
              # }
              # {
              #   timeout = 330;
              #   on-timeout = "hyprctl dispatch dpms off";
              #   on-resume = "hyprctl dispatch dpms on";
              # }
              {
                timeout = 1800;
                on-timeout = "systemctl suspend";
              }
            ];
          };
        };
      };
  };
}
