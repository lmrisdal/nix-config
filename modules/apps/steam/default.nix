{
  lib,
  config,
  username,
  defaultSession,
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
    use-steamos-session = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (pkgs.writeShellScriptBin "gamescope-session" ''
        #!/bin/bash
        # set autologin session back to default session so that "Switch to Desktop Mode" works
        cp /etc/sddm.conf /tmp/sddm.conf
        sed -i 's/^Session=.*/Session=${defaultSession}/' /tmp/sddm.conf
        cat /tmp/sddm.conf > /etc/sddm.conf
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
        # This is my extremely hacky way of switching between the SteamOS session and the Desktop session
        # NixOS keeps the sddm.conf file in the Nix store, so we can't just edit it directly
        # Instead, we make a copy of it and sets the current user as the owner of the file.
        # This allows us to edit in the Autologin section with relogin=true and the Session set to steam.desktop
        # The SteamOS session then sets the Session back to plasma.desktop when it starts so that we can use the "Switch to Desktop Mode" button in the SteamOS session.
        # This works, but if you see this and you know a better way to do this, please let me know! 🥲

        # TODO: parameterize the session name if we don't want to use Plasma

        # check if parameter = steamos
        if [ "$1" = "steamos" ]; then
          echo "Switching to Steam session"
          cp /etc/sddm.conf /tmp/sddm.conf
          echo -e "\n[Autologin]\nRelogin=true\nSession=steam.desktop\nUser=${username}" >> /tmp/sddm.conf
          cat /tmp/sddm.conf > /etc/sddm.conf
          rm -f /tmp/sddm.conf
          qdbus org.kde.Shutdown /Shutdown logout
        else
          echo "Switching to Desktop session"
          steam -shutdown
        fi

      '')
      (lib.mkIf cfg.use-steamos-session (
        pkgs.writeShellScriptBin "steamos-cleanup" ''
          #!/bin/bash
          cat /etc/sddm.d/10-nixos.conf > /etc/sddm.conf
        ''
      ))
    ];
    systemd.services.preparesteamos = lib.mkIf cfg.use-steamos-session {
      wantedBy = [ "multi-user.target" ];
      enable = true;
      serviceConfig = {
        User = "root";
        Group = "root";
      };
      script = ''
        #!/bin/sh
        # Part of the hacky way to switch between the SteamOS session and the Desktop session
        # This service runs at boot and prepares the sddm.conf file so that we can edit it without root permissions
        mv /etc/sddm.conf /etc/sddm.d/10-nixos.conf
        cat /etc/sddm.d/10-nixos.conf > /etc/sddm.conf
        chown ${username}:users /etc/sddm.conf
        chmod 644 /etc/sddm.conf
      '';
    };
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
        inputs.chaotic.packages.${pkgs.system}.proton-cachyos
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
            steamos-cleanup = {
              enable = cfg.use-steamos-session;
              text = ''
                [Desktop Entry]
                Name=SteamOS Cleanup
                Exec=steamos-cleanup
                Terminal=false
                Type=Application
              '';
              target = "${config.xdg.configHome}/autostart/steamos-cleanup.desktop";
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
            # return-to-gaming-mode = {
            #   text = ''
            #     [Desktop Entry]
            #     Name=Return to Gaming Mode
            #     Exec=steamos-session-select steamos
            #     Icon="${config.xdg.configHome}/deckify/steam-gaming-return.png" # why won't icon work??
            #     Terminal=false
            #     Type=Application
            #     StartupNotify=false"
            #   '';
            #   target = "/home/${username}/Desktop/Return_to_Gaming_Mode.desktop";
            # };
          };
          packages = with pkgs; [
            steamcmd
          ];
        };
        xdg.desktopEntries = {
          gamingmode = {
            name = "Gaming Mode";
            genericName = "Gaming Mode";
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
