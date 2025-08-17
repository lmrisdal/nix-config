{
  lib,
  config,
  pkgs,
  username,
  defaultSession,
  inputs,
  ...
}:
let
  cfg = config.hyprland;
in
{
  options = {
    hyprland = {
      enable = lib.mkEnableOption "Enable Hyprland in NixOS";
    };
  };
  config = lib.mkIf cfg.enable {
    sddm.enable = true;
    hyprpanel.enable = true;
    hyprlock.enable = true;
    wlogout.enable = true;

    xdg.portal = {
      extraPortals = with pkgs; [
        xdg-desktop-portal
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
      ];
    };
    services.dbus.enable = true;
    services.playerctld.enable = true;
    environment.systemPackages = with pkgs; [
      pyprland # plugin system
      hyprpicker # color picker
      hyprcursor # cursor format
      hypridle # idle daemon
      hyprpaper # wallpaper util
      swww # wallpaper util
      hyprshot # screenshot util
      helix # txt editor
      zathura # pdf viewer
      mpv # media player
      imv # image viewer
      blueberry # bluetooth
      pavucontrol # volume control
      nautilus # file manager
      ddcutil # control monitor brightness
      brightnessctl # control monitor brightness
      kdePackages.xwaylandvideobridge
      kdePackages.dolphin
      kdePackages.qt6ct
      kdePackages.ark
      libsForQt5.qt5ct
      glib
      gsettings-desktop-schemas
      gnome-control-center
      nwg-look
      swaynotificationcenter
      rose-pine-cursor
      rose-pine-hyprcursor
      kdePackages.qtmultimedia
      grim
      slurp
      networkmanagerapplet
      hyprpolkitagent
      nemo-with-extensions
      nemo-fileroller
      nemo-preview
      yad
      wl-clipboard
    ];
    programs.hyprland.enable = true;
    programs.hyprland.package = pkgs.hyprland;
    programs.hyprland.withUWSM = true;
    #programs.waybar.enable = true;
    programs.dconf.enable = true;
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";
    home-manager.users.${username} =
      {
        inputs,
        config,
        ...
      }:
      {
        gtk = {
          enable = true;
          theme = {
            name = "Adwaita-dark";
            package = pkgs.gnome-themes-extra;
          };
          gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
          gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
        };
        qt = {
          enable = true;
          style = {
            name = "adwaita-dark";
          };
        };
        dconf.settings = {
          "org/gnome/desktop/interface".color-scheme = "prefer-dark";
        };
        programs.eww = {
          enable = true;
          enableZshIntegration = true;
          enableBashIntegration = true;
          enableFishIntegration = true;
        };
      };
  };
}
