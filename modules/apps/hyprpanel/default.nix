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
    # environment.systemPackages = with pkgs; [
    #   hyprpanel
    # ];
    home-manager.users.${username} =
      { config, pkgs, ... }:
      {
        programs.hyprpanel = {
          enable = true;
          systemd.enable = true;
          settings = {
            bar = {
              launcher.autoDetectIcon = true;
              workspaces.show_icons = true;
              scrollSpeed = 5;
              clock = {
                format = "%a %b %d  %H:%M";
              };
              layouts = {
                "*" = {
                  left = [
                    "dashboard"
                    "workspaces"
                    "windowtitle"
                    # "ram"
                    # "cpu"
                    # "cputemp"
                  ];
                  middle = [
                    "media"
                  ];
                  right = [
                    "volume"
                    "systray"
                    "clock"
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
              power = {
                logout = "loginctl terminate-session '$XDG_SESSION_ID'";
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
                    shortcut4.command = "vicinae";
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
