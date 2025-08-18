{
  lib,
  config,
  pkgs,
  username,
  fullname,
  ...
}:
let
  cfg = config.hyprpanel;
in
{
  options = {
    hyprpanel = {
      enable = lib.mkEnableOption "Enable HyprPanel in home-manager";
    };
  };
  config = lib.mkIf cfg.enable {
    home-manager.users.${username} =
      { config, pkgs, ... }:
      {
        programs.hyprpanel = {
          enable = true;
          # systemd.enable = true;
          settings = {
            bar = {
              launcher.autoDetectIcon = true;
              workspaces.show_icons = true;
              scrollSpeed = 5;
            };
            layout = {
              bar.layouts = {
                "*" = {
                  left = [
                    "dashboard"
                    "workspaces"
                    "ram"
                    "cpu"
                    "cputemp"
                  ];
                  middle = [
                    "media"
                  ];
                  right = [
                    "volume"
                    "systray"
                    "notifications"
                  ];
                };
              };
            };
            menus = {
              clock = {
                time = {
                  military = true;
                  hideSeconds = true;
                };
                weather.unit = "metric";
                weather.location = "Oslo";
                weather.key = config.sops.secrets."weather.json".path;
              };
              dashboard = {
                directories = {
                  enabled = false;
                };
                stats = {
                  enable_gpu = true;
                };
                powermenu = {
                  avatar = {
                    image = "/home/lars/Pictures/lars.jpeg";
                  };
                };
                shortcuts = {
                  left = {
                    shortcut1.icon = "";
                    shortcut1.command = "zen";
                    shortcut1.tooltip = "Zen";
                    shortcut2.command = "flatpak run com.spotify.Client";
                    shortcut3.command = "vesktop";
                    shortcut3.tooltip = "Vesktop";
                    shortcut4.command = "rofi -show drun -show-icons";
                  };
                };
              };
            };
            theme = {
              bar = {
                transparent = true;
                floating = true;
                margin_top = "0.2em";
                margin_sides = "0px";
                margin_bottom = "-5px";
                buttons.radius = "10px";
                outer_spacing = "0.4em";
                clock = {
                  format = "%a %b %d  %I:%M %p";
                };
              };
              font = {
                name = "SF Pro";
                label = "SF Pro";
                size = "16px";
              };
            };
            scalingPriority = "hyprland";
          };
        };
      };
  };
}
