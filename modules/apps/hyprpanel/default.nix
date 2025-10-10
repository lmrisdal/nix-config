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
    environment.systemPackages = with pkgs; [
      python313Packages.gpustat
    ];
    home-manager.users.${username} =
      { config, pkgs, ... }:
      {
        programs.hyprpanel = {
          enable = true;
          dontAssertNotificationDaemons = false;
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
                    "custom/recording-active"
                    "custom/is_screen_sharing"
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
                    shortcut3.command = "discord";
                    shortcut3.tooltip = "Discord";
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
        xdg.configFile."hyprpanel/modules.json".source = pkgs.writeText "modules.json" (
          builtins.toJSON {
            "custom/is_screen_sharing" = {
              icon = "󱒃";
              label = "Sharing screen";
              execute = ''
                set -euo pipefail
                ${pkgs.pipewire}/bin/pw-dump 2>/dev/null | ${pkgs.jq}/bin/jq -r 'map(.info?.props?) | map(select(.["media.name"]? == "webrtc-consume-stream")) | map(.["stream.is-live"]? == true | "LIVE") | .[]?' 2>/dev/null || true
              '';
              interval = 2000;
              hideOnEmpty = true;
            };
            "custom/recording-active" = {
              icon = "";
              label = "{}";
              execute = ''
                if ${pkgs.procps}/bin/pgrep -x wf-recorder > /dev/null; then
                  echo "REC"
                else
                  echo ""
                fi
              '';
              interval = 1000;
              hideOnEmpty = true;
              actions = {
                onLeftClick = "stop-screen-recording";
              };
            };
          }
        );
        xdg.configFile."hyprpanel/modules.scss".text = ''
          @include styleModule(
            'cmodule-is_screen_sharing',
            (
              'icon-color': #CDD6F4, // Catppuccin Text
              'text-color': #CDD6F4 // Catppuccin Text
            )
          );
          @include styleModule(
            'cmodule-recording-active',
            (
              'text-color': #F38BA8, // Catppuccin Red
              'icon-color': #F38BA8
            )
          );
        '';
        # home.file = {
        #   custom-modules = {
        #     enable = true;
        #     text = ''
        #       {
        #         "custom/is_screen_sharing": {
        #           "icon": "󱒃",
        #           "execute": "is-screen-sharing",
        #           "interval": 2000,
        #           "hideOnEmpty": true,
        #           "label": "Sharing screen"
        #         }
        #       }
        #     '';
        #     target = "${config.xdg.configHome}/hyprpanel/modules.json";
        #   };
        # };
      };
  };
}
