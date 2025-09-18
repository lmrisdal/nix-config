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
    };
    home-manager.users.${username} =
      { pkgs, config, ... }:
      {
        home.packages = with pkgs; [ moondeck-buddy ];
        xdg.autostart.entries = with pkgs; [ "${moondeck-buddy}/share/applications/MoonDeckBuddy.desktop" ];
        home.file = {
          sunshine-autostart = {
            enable = true;
            text = ''
              [Desktop Entry]
              Name=sunshine
              Comment=sunshine Service
              Exec=sunshine
              StartupNotify=false
              Terminal=false
              Type=Application
            '';
            target = "${config.xdg.configHome}/autostart/sunshine.desktop";
          };
          sunshine-conf = {
            enable = true;
            text = ''
              av1_mode = 0
              back_button_timeout = 100
              capture = kms
              encoder = nvenc
              hevc_mode = 0
            '';
            target = "${config.xdg.configHome}/sunshine/sunshine.conf";
          };
          sunshine-apps = {
            enable = true;
            text = ''
              {
                "env": {
                  "PATH": "$(PATH):$(HOME)/.local/bin"
                },
                "apps": [
                  {
                    "name": "Desktop",
                    "image-path": "desktop.png"
                  },
                  {
                    "name": "MoonDeckStream",
                    "cmd": "${pkgs.moondeck-buddy}/bin/MoonDeckStream",
                    "exclude-global-prep-cmd": "false",
                    "elevated": "false"
                  },
                  {
                    "name": "Steam Big Picture",
                    "detached": [
                      "setsid steam steam://open/bigpicture"
                    ],
                    "prep-cmd": [
                      {
                        "do": "",
                        "undo": "setsid steam steam://close/bigpicture"
                      }
                    ],
                    "image-path": "steam.png"
                  }
                ]
              }
            '';
            target = "${config.xdg.configHome}/sunshine/apps.json";
          };
        };
      };
  };
}
