{
  lib,
  config,
  pkgs,
  username,
  defaultSession,
  ...
}:
let
  cfg = config.sddm;
  # custom-sddm-astronaut = pkgs.sddm-astronaut.override {
  #   embeddedTheme = "pixel_sakura"; # "jake_the_dog";
  # };
  customWallpaper = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/lmrisdal/nix-config/refs/heads/main/dots/girl-with-cigarette.png";
    sha256 = "sha256-qWSLcAOzdVbWkYXiBnyYxu3kNaSTY4KiS4C33OxOK/c=";
  };
in
{
  options = {
    sddm = {
      enable = lib.mkEnableOption "Enable SDDM in NixOS";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # custom-sddm-astronaut
      (sddm-chili-theme.override {
        themeConfig = {
          background = "${customWallpaper}";
        };
      })
      # libsForQt5.qt5.qtquickcontrols
      #kdePackages.qt6ct
      # (pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
      #   [General]
      #   background=${customWallpaper}
      # '')
    ];
    services.displayManager = {
      defaultSession = "${defaultSession}";
      autoLogin = {
        enable = false;
        user = username;
      };
      sddm = {
        enable = true;
        wayland.enable = true;
        # package = pkgs.kdePackages.sddm;
        enableHidpi = true;
        # theme = "sddm-astronaut-theme";
        theme = "chili";
        settings = {
          Theme = {
            Current = "chili"; # "sddm-astronaut-theme";
            CursorTheme = "rose-pine-cursor";
            CursorSize = 24;
            Font = "SF Pro";
          };
        };
        extraPackages = with pkgs; [
          # custom-sddm-astronaut
          sddm-chili-theme
        ];
        autoLogin.relogin = false;
      };
    };
    systemd.services.sddm-conf = {
      wantedBy = [ "multi-user.target" ];
      enable = true;
      description = "Move SDDM configuration to /etc/sddm.conf.d so that we can override it later if needed (e.g. for autologin)";
      serviceConfig = {
        User = "root";
        Group = "root";
      };
      script = ''
        #!/bin/sh
        mkdir -p /etc/sddm.conf.d
        chmod 777 /etc/sddm.conf.d
        cat /etc/sddm.conf > /etc/sddm.conf.d/10-system.conf
        rm /etc/sddm.conf
      '';
    };
    home-manager.users.${username} = { config, pkgs, ... }: { };
  };
}
