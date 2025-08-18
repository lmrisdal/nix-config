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
    hypridle.enable = true;
    wlogout.enable = false;

    xdg.portal = {
      extraPortals = with pkgs; [
        xdg-desktop-portal
        xdg-desktop-portal-hyprland
      ];
    };
    services.dbus.enable = true;
    services.playerctld.enable = true;
    environment.systemPackages = with pkgs; [
      pyprland # plugin system
      hyprpicker # color picker
      hyprcursor # cursor format
      hyprpaper # wallpaper util
      swww # wallpaper util
      hyprshot # screenshot util
      helix # txt editor
      zathura # pdf viewer
      mpv # media player
      imv # image viewer
      blueberry # bluetooth
      bluetui # bluetooth tui
      pavucontrol # volume control
      wiremix # volume control
      nautilus # file manager
      ddcutil # control monitor brightness
      brightnessctl # control monitor brightness
      kdePackages.xwaylandvideobridge
      gnome-control-center # env XDG_CURRENT_DESKTOP=GNOME gnome-control-center
      swaynotificationcenter
      rose-pine-cursor
      rose-pine-hyprcursor
      networkmanagerapplet
      #impala # wifi management
      hyprpolkitagent
      nemo-with-extensions # file manager
      nemo-fileroller # archive manager
      nemo-preview # image preview
      yad # dialog utility
      wl-clipboard # clipboard utils
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
