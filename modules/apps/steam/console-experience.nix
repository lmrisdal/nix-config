{
  lib,
  config,
  username,
  pkgs,
  inputs,
  defaultSession,
  ...
}:
let
  cfg = config.consoleExperience;
in
{
  options.consoleExperience = {
    enable = lib.mkEnableOption "Enable Steam Console Experience in NixOS";
    desktopSession = lib.mkOption {
      type = lib.types.str;
      #default = "gnome-session";
      default = "startplasma-wayland";
      description = "Command to start the desktop session, e.g., 'startplasma-wayland', 'gnome-session' or 'gamescope-session'.";
    };
    logoutCommand = lib.mkOption {
      type = lib.types.str;
      #default = "gnome-session-quit --logout --no-prompt"; # "qdbus org.kde.Shutdown /Shutdown logout";
      #default = "qdbus org.kde.Shutdown /Shutdown logout";
      default = "sudo systemctl restart display-manager"; # can be used for all sessions, but needs elevation
      description = "Command to log out of the desktop session, e.g., 'qdbus org.kde.Shutdown /Shutdown logout'.";
    };
    enableHDR = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    enableVRR = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };
  config = lib.mkIf cfg.enable {
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
        touch $XDG_RUNTIME_DIR/switch-to-steam
        ${cfg.logoutCommand}
      '')
      (pkgs.writeShellScriptBin "gamescope-session" ''
        #!/bin/bash
        # gamescope -- steam -steamdeck # run without -steamos3 in desktop mode first
        gamescope \
          ${lib.concatStringsSep " " (
            [
              "-r 240"
              "-w 3840"
              "-h 2160"
              "-W 3840"
              "-H 2160"
              "-O HDMI-A-1,DP-1"
              "--steam"
              "--rt"
              "--immediate-flips"
              "--mangoapp"
              "--force-grab-cursor"
              # "--backend sdl" # gnome 48 issue
            ]
            ++ lib.optionals cfg.enableHDR [
              "--hdr-enabled"
              #"--hdr-itm-enable"
            ]
            ++ lib.optionals cfg.enableVRR [ "--adaptive-sync" ]
            ++ [
              "--"
              "steam"
              "-steamos3"
              "-steamdeck"
              "-pipewire-dmabuf"
            ]
          )}
      '')
      (pkgs.writeShellScriptBin "load-session" ''
        #!/bin/sh
        # get parameter for session
        session="$1"

        if [ -r $XDG_RUNTIME_DIR/switch-to-steam ]; then
          rm $XDG_RUNTIME_DIR/switch-to-steam
          exec gamescope-session
        elif [ -r $XDG_RUNTIME_DIR/switch-to-desktop ]; then
          rm $XDG_RUNTIME_DIR/switch-to-desktop
          exec ${cfg.desktopSession}
        else
          if [ "${defaultSession}" = "steam" ]; then
            exec gamescope-session
          else
            exec ${cfg.desktopSession}
          fi
        fi
      '')
      (pkgs.writeShellScriptBin "steamos-session-select" ''
        #!/bin/bash
        touch $XDG_RUNTIME_DIR/switch-to-desktop
        steam -shutdown
      '')
    ];
    programs.steam = {
      gamescopeSession.enable = true;
    };
    services.displayManager.sessionPackages = lib.mkIf cfg.enable [
      (
        # Override the steam.desktop file to use the gamescope-session script
        (pkgs.writeTextDir "share/wayland-sessions/steam.desktop" ''
          [Desktop Entry]
          Name=SteamOS
          Comment=A digital distribution platform
          Exec=load-session steam
          Type=Application
        '').overrideAttrs
          (_: {
            passthru.providedSessions = [ "steam" ];
          })
      )
      (
        # Override the plasma.desktop file to use the gamescope-session script
        (pkgs.writeTextDir "share/wayland-sessions/plasma.desktop" ''
          [Desktop Entry]
          Name=Plasma
          Exec=load-session plasma
          Type=Application
        '').overrideAttrs
          (_: {
            passthru.providedSessions = [ "plasma" ];
          })
      )
      (
        # Override the gnome.desktop file to use the gamescope-session script
        (pkgs.writeTextDir "share/wayland-sessions/gnome.desktop" ''
          [Desktop Entry]
          Name=Gnome
          Exec=load-session gnome
          Type=Application
        '').overrideAttrs
          (_: {
            passthru.providedSessions = [ "gnome" ];
          })
      )
    ];
    home-manager.users.${username} =
      { pkgs, config, ... }:
      {
        home = {
          file = {
            "${config.xdg.configHome}/deckify/steam-gaming-return.png" = lib.mkIf cfg.enable {
              source = pkgs.fetchurl {
                url = "https://raw.githubusercontent.com/unlbslk/arch-deckify/refs/heads/main/icons/steam-gaming-return.png";
                sha256 = "sha256-Lc5y6jzhrtQAicXnyrr+LrsE7Is/Xbg5UeO0Blisz8I=";
              };
            };
            return-to-gaming-mode = {
              enable = cfg.enable;
              text = ''
                [Desktop Entry]
                Name=Gaming Mode
                Exec=switch-to-steamos
                Icon=${config.xdg.configHome}/deckify/steam-gaming-return.png
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
            name = "Gaming Mode";
            genericName = "Gaming Mode";
            exec = "switch-to-steamos";
            terminal = false;
            categories = [
              "Application"
              "Network"
            ];
            icon = "${config.xdg.configHome}/deckify/steam-gaming-return.png";
          };
        };
      };
  };
}
