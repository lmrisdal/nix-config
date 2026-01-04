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
    networking = {
      firewall = {
        allowedUDPPorts = [
          # Moonlight
          5353
          47998
          47999
          48000
          48002
          48010
        ];
        allowedTCPPorts = [
          # MoonDeck Buddy
          59999
          # Moonlight
          47984
          47989
          48010
        ];
      };
    };
    services.sunshine = {
      enable = true;
      autoStart = false; # Seems to have issue using KMS with this autostart option. Use desktop file instead.
      capSysAdmin = true;
      openFirewall = true;
      package = pkgs.sunshine.override { cudaSupport = true; };
      # applications.apps doesn't seem to do anything? using home-manager to manage apps.json instead
    };
    home-manager.users.${username} =
      { pkgs, config, ... }:
      {
        # home.packages = with pkgs; [ moondeck-buddy ];
        # xdg.autostart.entries = with pkgs; [ "${moondeck-buddy}/share/applications/MoonDeckBuddy.desktop" ];
        home.file = {
          # sunshine-autostart = {
          #   enable = true;
          #   text = ''
          #     [Desktop Entry]
          #     Name=sunshine
          #     Comment=sunshine Service
          #     Exec=sunshine
          #     StartupNotify=false
          #     Terminal=false
          #     Type=Application
          #   '';
          #   target = "${config.xdg.configHome}/autostart/sunshine.desktop";
          # };
          sunshine-conf = {
            enable = true;
            text = ''
              av1_mode = 0
              back_button_timeout = 200
              capture = kms
              encoder = nvenc
              hevc_mode = 0
            '';
            target = "${config.xdg.configHome}/sunshine/sunshine.conf";
          };
          sunshine-apps =
            let
              configureDisplay = (
                pkgs.writeShellScript "configureDisplay" ''
                  # Configure display to match client
                  if [ "$SUNSHINE_CLIENT_FPS" -gt 120 ]; then
                    SUNSHINE_CLIENT_FPS=120
                  fi
                  local hdr_param=$1
                  if [[ "$1" == "hdr" ]]; then
                    hypr-toggle-hdr on
                  elif [[ "$1" == "sdr" ]]; then
                    hypr-toggle-hdr off
                  else
                    if [[ "$SUNSHINE_CLIENT_HDR" =~ ^(true|1|yes|on)$ ]]; then
                      hypr-toggle-hdr on
                    else
                      hypr-toggle-hdr off
                    fi
                  fi
                  hypr-set-resolution $SUNSHINE_CLIENT_WIDTH $SUNSHINE_CLIENT_HEIGHT $SUNSHINE_CLIENT_FPS
                ''
              );
              revertDisplay = (
                pkgs.writeShellScript "revertDisplay" ''
                  hypr-reset-resolution
                  hypr-toggle-hdr off
                ''
              );
              gamescopeConfig = pkgs.writeShellScript "gamescopeConfig" ''
                echo "killing existing gamescope instances"
                ${pkgs.procps}/bin/pgrep -f steam | xargs -r kill -9
                ${pkgs.procps}/bin/pgrep -f gamescopereaper | xargs -r kill -9
                ${pkgs.systemd}/bin/systemctl --user reset-failed
                ${pkgs.systemd}/bin/systemctl --user stop -job-mode=replace-irreversibly sunshine-steam.service 2> /dev/null || true
                ${pkgs.systemd}/bin/systemctl --user reset-failed
                if [[ "$1" == "hdr" ]]; then
                  echo "Starting gamescope with HDR enabled"
                  #gamescope -r "$SUNSHINE_CLIENT_FPS" -W "$SUNSHINE_CLIENT_WIDTH" -w "$SUNSHINE_CLIENT_WIDTH" -H "$SUNSHINE_CLIENT_HEIGHT" -h "$SUNSHINE_CLIENT_HEIGHT" -e --hdr-enabled -- steam -tenfoot -pipewire-dmabuf -console -cef-force-gpu &
                  #disown
                  ${pkgs.systemd}/bin/systemd-run --user \
                  --unit=sunshine-steam \
                  --description="Launch Steam Gamescope detached in desktop session" \
                  --setenv=SUNSHINE_CLIENT_FPS="$SUNSHINE_CLIENT_FPS" \
                  --setenv=SUNSHINE_CLIENT_WIDTH="$SUNSHINE_CLIENT_WIDTH" \
                  --setenv=SUNSHINE_CLIENT_HEIGHT="$SUNSHINE_CLIENT_HEIGHT" \
                  ${pkgs.bash}/bin/bash -lc 'exec gamescope -r "$SUNSHINE_CLIENT_FPS" -W "$SUNSHINE_CLIENT_WIDTH" -w "$SUNSHINE_CLIENT_WIDTH" -H "$SUNSHINE_CLIENT_HEIGHT" -h "$SUNSHINE_CLIENT_HEIGHT" -e --hdr-enabled -- steam -tenfoot -pipewire-dmabuf -console -cef-force-gpu'
                else
                  echo "Starting gamescope with HDR disabled"
                  #gamescope -r "$SUNSHINE_CLIENT_FPS" -W "$SUNSHINE_CLIENT_WIDTH" -w "$SUNSHINE_CLIENT_WIDTH" -H "$SUNSHINE_CLIENT_HEIGHT" -h "$SUNSHINE_CLIENT_HEIGHT" -e -- steam -tenfoot -pipewire-dmabuf -console -cef-force-gpu &
                  #disown
                  ${pkgs.systemd}/bin/systemd-run --user \
                  --unit=sunshine-steam \
                  --description="Launch Steam Gamescope detached in desktop session" \
                  --setenv=SUNSHINE_CLIENT_FPS="$SUNSHINE_CLIENT_FPS" \
                  --setenv=SUNSHINE_CLIENT_WIDTH="$SUNSHINE_CLIENT_WIDTH" \
                  --setenv=SUNSHINE_CLIENT_HEIGHT="$SUNSHINE_CLIENT_HEIGHT" \
                  ${pkgs.bash}/bin/bash -lc 'exec gamescope -r "$SUNSHINE_CLIENT_FPS" -W "$SUNSHINE_CLIENT_WIDTH" -w "$SUNSHINE_CLIENT_WIDTH" -H "$SUNSHINE_CLIENT_HEIGHT" -h "$SUNSHINE_CLIENT_HEIGHT" -e -- steam -tenfoot -pipewire-dmabuf -console -cef-force-gpu'
                fi
              '';
              stopGamescope = pkgs.writeShellScript "stopGamescope" ''
                ${pkgs.procps}/bin/pgrep -f steam | xargs -r kill -9
                ${pkgs.procps}/bin/pgrep -f gamescopereaper | xargs -r kill -9
                ${pkgs.systemd}/bin/systemctl --user reset-failed
                ${pkgs.systemd}/bin/systemctl --user stop -job-mode=replace-irreversibly sunshine-steam.service 2> /dev/null || true
                ${pkgs.systemd}/bin/systemctl --user kill -s SIGKILL sunshine-steam.service 2> /dev/null || true
                ${pkgs.systemd}/bin/systemctl --user reset-failed
                sleep 1
                ${pkgs.hyprland}/bin/hyprctl dispatch exec steam -- -silent
                ${pkgs.systemd}/bin/systemctl --user reset-failed
              '';
            in
            {
              enable = true;
              text = ''
                {
                  "env": {
                    "PATH": "$(PATH):$(HOME)/.local/bin"
                  },
                  "apps": [
                    {
                      "name": "Desktop (HDR)",
                      "image-path": "${./desktop_hdr.png}",
                      "prep-cmd": [
                        {
                          "do": "${configureDisplay} hdr",
                          "undo": "${revertDisplay}"
                        }
                      ]
                    },
                    {
                      "name": "Desktop (SDR)",
                      "image-path": "desktop.png",
                      "prep-cmd": [
                        {
                          "do": "${configureDisplay} sdr",
                          "undo": "${revertDisplay}"
                        }
                      ]
                    },
                    {
                      "name": "Steam (HDR)",
                      "prep-cmd": [
                        {
                          "do": "${configureDisplay} hdr",
                          "undo": "${revertDisplay}"
                        },
                        {
                          "do": "${gamescopeConfig} hdr",
                          "undo": "${stopGamescope}"
                        }
                      ],
                      "image-path": "${./steam_hdr.png}"
                    },
                    {
                      "name": "Steam (SDR)",
                      "prep-cmd": [
                        {
                          "do": "${configureDisplay} sdr",
                          "undo": "${revertDisplay}"
                        },
                        {
                          "do": "${gamescopeConfig} sdr",
                          "undo": "${stopGamescope}"
                        }
                      ],
                      "image-path": "steam.png"
                    }
                    # {
                    #   "name": "MoonDeckStream",
                    #   "cmd": "${pkgs.moondeck-buddy}/bin/MoonDeckStream",
                    #   "exclude-global-prep-cmd": "false",
                    #   "elevated": "false",
                    #   "prep-cmd": [
                    #     {
                    #       "do": "${configureDisplay}",
                    #       "undo": "${revertDisplay}"
                    #     }
                    #   ]
                    # }
                  ]
                }
              '';
              target = "${config.xdg.configHome}/sunshine/apps.json";
            };
        };
      };
  };
}
