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
    desktopSession = lib.mkOption {
      type = lib.types.str;
      default = "startplasma-wayland";
      description = "Used as a fallback if something should go wrong. This should be 'startplasma-wayland', 'gnome-session', 'hyprland', 'sway' etc.";
    };
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
        echo -e "\n[Autologin]\nRelogin=true" > /etc/sddm.conf.d/50-autologin.conf

        sudo restart-displaymanager
      '')
      (pkgs.writeShellScriptBin "restart-displaymanager" ''
        #!/bin/bash
        sudo systemctl restart display-manager
      '')
      (pkgs.writeShellScriptBin "load-session" ''
        #!/bin/sh
        MAIN_SESSION="$1" # the session defined in the desktop file
        STEAM_SESSION="steam-gamescope"
        FALLBACK_SESSION="${cfg.desktopSession}"

        if [ -r $XDG_RUNTIME_DIR/switch-to-steam ]; then
          rm $XDG_RUNTIME_DIR/switch-to-steam
          exec $STEAM_SESSION
        elif [ -r $XDG_RUNTIME_DIR/switch-to-desktop ]; then
          DESKTOP_SESSION=$(cat $XDG_RUNTIME_DIR/switch-to-desktop)
          rm $XDG_RUNTIME_DIR/switch-to-desktop
          echo "Switching to session: $DESKTOP_SESSION"
          if [ -z "$DESKTOP_SESSION" ]; then
            echo "No desktop session specified, falling back to: $FALLBACK_SESSION"
            exec $FALLBACK_SESSION
          else
            exec $DESKTOP_SESSION
          fi
        elif [ -z "$MAIN_SESSION" ]; then
          echo "No main session specified, falling back to: $FALLBACK_SESSION"
          exec $FALLBACK_SESSION
        else
          exec $MAIN_SESSION
        fi
      '')
      (pkgs.writeShellScriptBin "steamos-session-select" ''
        #!/bin/bash
        echo "${cfg.desktopSession}" > $XDG_RUNTIME_DIR/switch-to-desktop
        steam -shutdown
      '')
      (pkgs.writeShellScriptBin "steamos-cleanup" ''
        #!/bin/bash
        # Remove autologin configuration when switching to desktop
        rm /etc/sddm.conf.d/50-autologin.conf
        rm $XDG_RUNTIME_DIR/switch-to-desktop
        rm $XDG_RUNTIME_DIR/switch-to-steam
      '')
    ];
    security.sudo.extraRules = [
      {
        users = [ username ];
        commands = [
          # Make it so we don't need root to switch to gaming mode
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

    # Sets the default session at launch
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
        displayProductName=$(edid-decode /sys/class/drm/card1-HDMI-A-1/edid | grep "Display Product Name" | cut -d"'" -f2)
        if [[ "$displayProductName" == *"LG TV"* ]]; then
          echo -e "\n[Autologin]\nSession=steam\nEnable=true" > /etc/sddm.conf.d/20-defaultsession.conf
        fi
      '';
    };

    # #!/bin/sh
    # # Get the maximum width for 16:9 modes using xrandr
    # xrandr --props | awk '/^[ ]*[0-9]+x[0-9]+[ ]+[0-9]+\.[0-9]+/ {
    #   split($1, res, "x");
    #   width=res[1]; height=res[2];
    #   if (width/height == 16/9 && width > max) max=width
    # } END { print max }'

    # #!/bin/sh
    # # Get the maximum height for 16:9 modes using xrandr
    # xrandr --props | awk '/^[ ]*[0-9]+x[0-9]+[ ]+[0-9]+\.[0-9]+/ {
    #   split($1, res, "x");
    #   width=res[1]; height=res[2];
    #   if (width/height == 16/9 && height > max) max=height
    # } END { print max }'

    # #!/bin/sh
    # # Get the maximum refresh rate for 16:9 modes using xrandr, rounded to nearest integer
    # xrandr --props | awk '
    # /^[ ]*[0-9]+x[0-9]+[ ]+[0-9]+\.[0-9]+/ {
    #   split($1, res, "x");
    #   width=res[1]; height=res[2];
    #   if (width/height == 16/9 && $2+0 > max) max=$2+0
    # }
    # END {
    #   printf "%.0f\n", max
    # }'

    programs.steam = {
      gamescopeSession = {
        enable = true;
        env = {
          ENABLE_HDR_WSI = if cfg.enableHDR then "1" else "0";
          ENABLE_VRR = if cfg.enableVRR then "1" else "0";
        };
        args = lib.mkMerge [
          [
            "-r 240"
            "-w 3840"
            "-h 2160"
            "-W 3840"
            "-H 2160"
            "-O HDMI-A-1,DP-1,*"
            "--rt"
            "--immediate-flips"
            "--mangoapp"
            "--force-grab-cursor"
            # "--backend sdl" # gnome 48 issue
          ]
          (lib.mkIf cfg.enableHDR [
            "--hdr-enabled"
            "--hdr-itm-enable"
          ])
          (lib.mkIf cfg.enableVRR [
            "--adaptive-sync"
          ])
        ];
        steamArgs = [
          "-steamos3" # run without -steamos3 in desktop mode first
          "-steamdeck"
          #"-tenfoot"
          "-pipewire-dmabuf"
        ];
      };
    };
    services.displayManager.sessionPackages = lib.mkIf cfg.enable [
      (
        # Override the steam.desktop file to use the gamescope-session script
        (pkgs.writeTextDir "share/wayland-sessions/steam.desktop" ''
          [Desktop Entry]
          Name=SteamOS
          Comment=A digital distribution platform
          Exec=load-session steam-gamescope
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
          Exec=load-session startplasma-wayland
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
          Exec=load-session gnome-session
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
