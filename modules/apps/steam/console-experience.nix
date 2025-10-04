{
  lib,
  config,
  pkgs,
  inputs,
  username,
  defaultSession,
  ...
}:
let
  cfg = config.consoleExperience;
in
{
  options.consoleExperience = {
    enable = lib.mkEnableOption "Enable Steam Console Experience in NixOS";
    enableHDR = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    enableVRR = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    enableDesktopShortcut = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };
  config = lib.mkIf cfg.enable {
    environment.sessionVariables = {
      DESKTOP_SESSION = "${defaultSession}";
    };
    environment.systemPackages = with pkgs; [
      (pkgs.writeShellScriptBin "jupiter-biosupdate" ''
        #!/bin/bash
        exit 0;
      '')
      (pkgs.writeShellScriptBin "steamos-select-branch" ''
        #!/bin/bash
        echo "Not applicable for this OS"
      '')
      (pkgs.writeShellScriptBin "steamos-update" ''
        #!/bin/bash
        exit 7;
      '')
      (pkgs.writeShellScriptBin "switch-to-steamos" ''
        #!/bin/bash
        set -euo pipefail
        #echo -e "\n[Autologin]\nUser=${username}\nRelogin=true\nSession=steam" > /etc/sddm.conf.d/50-autologin.conf
        #sudo restart-displaymanager
        mkdir -p ~/.local/state
        >~/.local/state/steamos-session-select echo "steam"
        if pgrep -x steam >/dev/null; then
            echo "Shutting down Steam..."
            steam -shutdown
            while pgrep -x steam >/dev/null; do
                sleep 1
            done
            echo "Steam closed."
        fi
        loginctl terminate-user "${username}"
        #hyprctl dispatch exit
      '')
      (pkgs.writeShellScriptBin "restart-displaymanager" ''
        #!/bin/bash
        sudo systemctl restart display-manager
      '')
      (pkgs.writeShellScriptBin "steamos-session-select" ''
        #!/bin/bash
        steam -shutdown
      '')
      (pkgs.writeShellScriptBin "steamos-cleanup" ''
        #!/bin/bash
        # Remove autologin configuration when switching to desktop
        #rm /etc/sddm.conf.d/50-autologin.conf
        rm $XDG_RUNTIME_DIR/switch-to-desktop
        rm $XDG_RUNTIME_DIR/switch-to-steam
      '')
      (pkgs.writeShellScriptBin "get-screen-device-name" ''
        #!/bin/bash
        echo $(${pkgs.edid-decode}/bin/edid-decode /sys/class/drm/card1-HDMI-A-1/edid | grep "Display Product Name" | cut -d"'" -f2)
      '')
      (pkgs.writeShellScriptBin "get-screen-width" ''
        #!/bin/bash
        width=$(${pkgs.edid-decode}/bin/edid-decode /sys/class/drm/card1-HDMI-A-1/edid 2>/dev/null | grep -oP '\b\d+x\d+\b' | cut -dx -f1 | sort -n | tail -1)
        if [[ -z "$width" || "$width" -eq 0 || "$width" -gt 3840 ]]; then
          echo "3840"
        else
          echo "$width"
        fi
      '')
      (pkgs.writeShellScriptBin "get-screen-height" ''
        #!/bin/bash
        height=$(${pkgs.edid-decode}/bin/edid-decode /sys/class/drm/card1-HDMI-A-1/edid 2>/dev/null | grep -oP '[0-9]{3,5}x[0-9]{3,5}' | cut -dx -f2 | sort -n | tail -1)
        if [[ -z "$height" || "$height" -eq 0 ]]; then
          echo "2160"
        else
          echo "$height"
        fi
      '')
      (pkgs.writeShellScriptBin "get-screen-refresh-rate" ''
        #!/bin/bash
        device_name=$(get-screen-device-name)
        if [[ "$device_name" == "LG TV SSCR2" ]]; then
          echo "120"
        else
          refresh=$(${pkgs.edid-decode}/bin/edid-decode /sys/class/drm/card1-HDMI-A-1/edid 2>/dev/null | grep "Maximum Refresh Rate" | cut -d"'" -f2 | awk '{print $4}')
          if [[ -z "$refresh" || "$refresh" -eq 0 ]]; then
            echo "60"
          else
            echo "$refresh"
          fi
        fi
      '')
      (pkgs.writeShellScriptBin "gamescope-session" ''
        #!/bin/bash
        #echo -e "\n[Autologin]\nUser=${username}\nRelogin=true\nSession=${defaultSession}" > /etc/sddm.conf.d/50-autologin.conf
        mkdir -p ~/.local/state
        >~/.local/state/steamos-session-select echo "${defaultSession}"
        export ENABLE_HDR_WSI=1
        export ENABLE_VRR=1
        width=$(get-screen-width)
        height=$(get-screen-height) 
        refresh_rate=$(get-screen-refresh-rate)
        exec gamescope \
          --steam \
          -r $refresh_rate \
          -w $width -h $height \
          -W $width -H $height \
          -O HDMI-A-1,DP-1,* \
          --rt \
          --immediate-flips \
          --mangoapp \
          --force-grab-cursor \
          --hdr-enabled \
          --hdr-itm-enable \
          --adaptive-sync \
          -- steam -steamos3 -steampal -steamdeck -gamepadui -pipewire-dmabuf # run without -steamos3 from terminal first
          sleep 5
          systemctl --user start --now sunshine
      '')
    ];
    security.sudo.extraRules = [
      {
        users = [ username ];
        commands = [
          # Make it so we don't need to elevate to switch to gaming mode
          {
            command = "/run/current-system/sw/bin/restart-displaymanager";
            options = [
              "SETENV"
              "NOPASSWD"
            ];
          }
        ];
      }
    ];

    # Boot to SteamOS when connected to my LG TV
    systemd.services.set-session = {
      wantedBy = [ "multi-user.target" ];
      before = [ "display-manager.service" ];
      enable = true;
      serviceConfig = {
        User = "root";
        Group = "root";
      };
      path = [ "/run/current-system/sw" ];
      script = ''
        #!/bin/sh
        displayProductName=$(${pkgs.edid-decode}/bin/edid-decode /sys/class/drm/card1-HDMI-A-1/edid | grep "Display Product Name" | cut -d"'" -f2)
        if [[ "$displayProductName" == *"LG TV"* ]]; then
          # echo -e "\n[Autologin]\nUser=${username}\nSession=steam\nEnable=true" > /etc/sddm.conf.d/20-defaultsession.conf
          mkdir -p ~/.local/state
          >~/.local/state/steamos-session-select echo "steam"
        fi
      '';
    };

    programs.steam = {
      gamescopeSession = {
        enable = true;
      };
    };
    services.displayManager.sessionPackages = lib.mkIf cfg.enable [
      (
        # Override the steam.desktop file to use the gamescope-session script
        (pkgs.writeTextDir "share/wayland-sessions/steam.desktop" ''
          [Desktop Entry]
          Name=SteamOS
          Comment=A digital distribution platform
          Exec=gamescope-session
          Type=Application
        '').overrideAttrs
          (_: {
            passthru.providedSessions = [ "steam" ];
          })
      )
    ];
    home-manager.users.${username} =
      { pkgs, config, ... }:
      {
        home = {
          file = {
            "${config.xdg.configHome}/icons/steam-gaming-return.png" = lib.mkIf cfg.enable {
              source = pkgs.fetchurl {
                url = "https://raw.githubusercontent.com/unlbslk/arch-deckify/refs/heads/main/icons/steam-gaming-return.png";
                sha256 = "sha256-Lc5y6jzhrtQAicXnyrr+LrsE7Is/Xbg5UeO0Blisz8I=";
              };
            };
            steamos-cleanup = {
              enable = cfg.enable;
              text = ''
                [Desktop Entry]
                Name=SteamOS Cleanup
                Exec=steamos-cleanup
                Terminal=false
                Type=Application
              '';
              target = "${config.xdg.configHome}/autostart/steamos-cleanup.desktop";
            };
            gaming-mode-desktop-shortcut = {
              enable = cfg.enableDesktopShortcut;
              text = ''
                [Desktop Entry]
                Name=Gaming Mode
                Exec=switch-to-steamos
                Icon=${config.xdg.configHome}/icons/steam-gaming-return.png
                Terminal=false
                Type=Application
                StartupNotify=false"
              '';
              target = "/home/${username}/Desktop/Return_to_Gaming_Mode.desktop";
            };
          };
        };
        xdg.desktopEntries = lib.mkIf cfg.enable {
          gamingmode = {
            name = "Switch to Gaming Mode";
            genericName = "Switch to Gaming Mode";
            exec = "switch-to-steamos";
            terminal = false;
            categories = [
              "Application"
              "Network"
            ];
            icon = "${config.xdg.configHome}/icons/steam-gaming-return.png";
          };
        };
      };
  };
}
