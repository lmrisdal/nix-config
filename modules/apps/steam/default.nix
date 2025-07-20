{
  lib,
  config,
  username,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.steam;
in
{
  options.steam = {
    enable = lib.mkEnableOption "Enable Steam in NixOS";
    enableFlatpak = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    enableNative = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    enableSteamBeta = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    # https://reddit.com/r/linux_gaming/comments/16e1l4h/slow_steam_downloads_try_this/
    fixDownloadSpeed = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    autostart = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    session-select = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (pkgs.writeShellScriptBin "gamescope-session" ''
        #!/bin/bash
        gamescope -w 3840 -h 2160 -W 3840 -H 2160 -O HDMI-A-1 --hdr-enabled --adaptive-sync -e -- steam -steamdeck -steamos3
      '')
      (pkgs.writeShellScriptBin "jupiter-biosupdate" ''
        #!/bin/bash
        exit 0;
      '')
      (pkgs.writeShellScriptBin "steamos-select-branch" ''
        #!/bin/bash
        echo "Not applicable for this OS"
      '')
      (pkgs.writeShellScriptBin "steamos-session-select" ''
        #!/bin/bash
        # check if parameter = plasma
        if [ "$1" = "steamos" ]; then
          echo "Switching to Steam session"
          cp /etc/sddm.conf /tmp/sddm.conf
          sed -i 's/^Session=.*/Session=steam.desktop/' /tmp/sddm.conf
          cat /tmp/sddm.conf > /etc/sddm.conf
          qdbus org.kde.Shutdown /Shutdown logout
        else
          echo "Switching to Plasma session"
          # sudo mv /etc/sddm.conf /etc/sddm.d/10-nixos.conf
          # steam -shutdown
          #bash -c 'echo -e "[Autologin]\nSession=plasma.desktop" > /etc/sddm.conf'
          #echo -e "[Autologin]\nSession=plasma.desktop" > /etc/sddm.conf
          cp /etc/sddm.conf /tmp/sddm.conf
          sed -i 's/^Session=.*/Session=plasma.desktop/' /tmp/sddm.conf
          cat /tmp/sddm.conf > /etc/sddm.conf
          steam -shutdown
        fi

      '')
      (lib.mkIf cfg.session-select (
        pkgs.writeShellScriptBin "nixswitch" ''
          #!/bin/bash
          # Run the NixOS rebuild switch command with the provided arguments
          sudo nixos-rebuild switch --flake ~/.config/nix-config/
        ''
      ))
      (lib.mkIf cfg.session-select (
        pkgs.writeShellScriptBin "nixtest" ''
          #!/bin/bash
          # Run the NixOS rebuild test command with the provided arguments
          sudo nixos-rebuild test --flake ~/.config/nix-config/
        ''
      ))
    ];
    systemd.services.preparesteamos = {
      wantedBy = [ "multi-user.target" ];
      enable = true;
      serviceConfig = {
        User = "root";
        Group = "root";
      };
      script = ''
        mv /etc/sddm.conf /etc/sddm.d/10-nixos.conf
        # Copy contents of /etc/sddm.d/10-nixos.conf into new /etc/sddm.conf file
        cat /etc/sddm.d/10-nixos.conf > /etc/sddm.conf
        chown lars:users /etc/sddm.conf
        chmod 644 /etc/sddm.conf
        # sed -i 's/^Session=.*/Session=steam.desktop/' /etc/sddm.conf
        #echo -e "[Autologin]\nSession=plasma.desktop" > /etc/sddm.conf
        #chown lars:users /etc/sddm.conf
        #chmod 644 /etc/sddm.conf
      '';
    };
    # system.activationScripts.script.text = ''
    #   #!/bin/bash
    #   # check if /etc/sddm.conf exists
    #   if [ -f /etc/sddm.conf ]; then
    #     echo "Moving /etc/sddm.conf to /etc/sddm.d/10
    #     mv /etc/sddm.conf /etc/sddm.d/10-nixos.conf
    #   fi
    #   # create /etc/sddm.conf with autologin to plasma
    #   bash -c 'echo -e "[Autologin]\nSession=steam.desktop" > /etc/sddm.conf'
    # '';
    programs.steam = {
      enable = cfg.enableNative;
      package = pkgs.steam.override {
        extraEnv = {
          MANGOHUD = true;
          OBS_VKCAPTURE = true;
          PROTON_ENABLE_WAYLAND = true;
          PROTON_ENABLE_HDR = true;
          PROTON_USE_NTSYNC = true;
          PROTON_USE_WOW64 = true;
          PULSE_SINK = "Game";
        };
        # https://github.com/NixOS/nixpkgs/issues/279893#issuecomment-2425213386
        extraProfile = ''
          unset TZ
        '';
      };
      dedicatedServer.openFirewall = true;
      extraCompatPackages = with pkgs; [
        luxtorpeda
        # inputs.nix-proton-cachyos.packages.${system}.proton-cachyos
        proton-ge-bin
      ];
      gamescopeSession.enable = true;
      localNetworkGameTransfers.openFirewall = true;
      protontricks.enable = true;
      remotePlay.openFirewall = true;
    };
    services.displayManager.sessionPackages = [
      (
        (pkgs.writeTextDir "share/wayland-sessions/steam.desktop" ''
          [Desktop Entry]
          Name=SteamOS (gamescope)
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
            steam-beta = {
              enable = cfg.enableSteamBeta;
              text = "publicbeta";
              target = "${config.xdg.dataHome}/Steam/package/beta";
            };
            steam-slow-fix = {
              enable = cfg.fixDownloadSpeed;
              text = ''
                @nClientDownloadEnableHTTP2PlatformLinux 0
                @fDownloadRateImprovementToAddAnotherConnection 1.0
                unShaderBackgroundProcessingThreads 8
              '';
              target = "${config.xdg.dataHome}/Steam/steam_dev.cfg";
            };
            steam-autostart = {
              enable = cfg.autostart;
              text = ''
                [Desktop Entry]
                Name=Steam
                Exec=steam -silent
                Icon=steam
                Terminal=false
                Type=Application
                MimeType=x-scheme-handler/steam;x-scheme-handler/steamlink;
                Actions=Store;Community;Library;Servers;Screenshots;News;Settings;BigPicture;Friends;
                PrefersNonDefaultGPU=true
                X-KDE-RunOnDiscreteGpu=true
              '';
              target = "${config.xdg.configHome}/autostart/steam.desktop";
            };
            "${config.xdg.configHome}/deckify/steam-gaming-return.png" = {
              source = pkgs.fetchurl {
                url = "https://raw.githubusercontent.com/unlbslk/arch-deckify/refs/heads/main/icons/steam-gaming-return.png";
                sha256 = "sha256-Lc5y6jzhrtQAicXnyrr+LrsE7Is/Xbg5UeO0Blisz8I=";
              };
            };
            return-to-gaming-mode = {
              text = ''
                [Desktop Entry]
                Name=Return to Gaming Mode
                Exec=steamos-session-select steamos
                Icon="${config.xdg.configHome}/deckify/steam-gaming-return.png"
                Terminal=false
                Type=Application
                StartupNotify=false"
              '';
              target = "/home/lars/Desktop/Return_to_Gaming_Mode.desktop";
            };
          };
          packages = with pkgs; [
            steamcmd
          ];
        };
        xdg.desktopEntries = {
          gamingmode = {
            name = "Return to Gaming Mode";
            genericName = "Return to Gaming Mode";
            exec = "steamos-session-select steamos";
            terminal = false;
            categories = [
              "Application"
              "Network"
            ];
            icon = "${config.xdg.configHome}/deckify/steam-gaming-return.png";
          };
        };
        services.flatpak = lib.mkIf cfg.enableFlatpak {
          overrides = {
            "com.valvesoftware.Steam" = {
              Context = {
                filesystems = [
                  "${config.home.homeDirectory}/Games"
                  "${config.xdg.dataHome}/applications"
                  "${config.xdg.dataHome}/games"
                  "${config.xdg.dataHome}/Steam"
                ];
              };
              Environment = {
                PULSE_SINK = "Game";
              };
              "Session Bus Policy" = {
                org.freedesktop.Flatpak = "talk";
              };
            };
          };
          packages = [
            "com.valvesoftware.Steam"
          ];
        };
      };
  };
}
