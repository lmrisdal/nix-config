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
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (pkgs.writeShellScriptBin "gamescope-session" ''
        #!/bin/bash
        gamescope -r 120 --mangoapp -e -- steam -steamdeck -steamos3
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
        GAMESCOPE_SESSION_SCRIPT="/usr/lib/os-session-select"
        if [ -f $GAMESCOPE_SESSION_SCRIPT ] ; then
        	# Call session script from the OS
        	${GAMESCOPE_SESSION_SCRIPT} $@
        else
        	# Simply call shutdown on the client
        	steam -shutdown
        fi
      '')
    ];
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
          Name=Steam (gamescope)
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
                Name=Gaming Mode
                Exec=steamos-session-select gamescope
                Icon="${config.xdg.configHome}/deckify/steam-gaming-return.png"
                Terminal=false
                Type=Application
                StartupNotify=false"
              '';
              target = "${config.home.homeDirectory}/Desktop/Return_to_Gaming_Mode.desktop";
            };
          };
          packages = with pkgs; [
            steamcmd
          ];
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
