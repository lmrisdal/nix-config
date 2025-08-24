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
    hyprlock.enable = true;
    hypridle.enable = true;
    hyprpanel.enable = true;
    # wlogout.enable = false;
    # programs.waybar.enable = true;

    xdg.portal = {
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
      ];
    };
    boot.kernelModules = [ "i2c-dev" ];
    services.udev.extraRules = ''
      KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
    '';
    services.dbus.enable = true;
    services.playerctld.enable = true;
    environment.systemPackages = with pkgs; [
      pyprland # plugin system
      hyprpicker # color picker
      hyprcursor # cursor format
      hyprpaper # wallpaper util
      swww # wallpaper util
      hyprshot # screenshot util
      swappy # screenshot annotation
      satty # screenshot annotation
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
      gnome-control-center # env XDG_CURRENT_DESKTOP=GNOME GDK_BACKEND=x11 gnome-control-center
      #swaynotificationcenter
      rose-pine-cursor
      rose-pine-hyprcursor
      networkmanagerapplet
      #impala # wifi management
      # hyprpolkitagent
      nemo-with-extensions # file manager
      nemo-fileroller # archive manager
      nemo-preview # image preview
      yad # dialog utility
      wl-clipboard # clipboard utils
    ];
    programs.hyprland.enable = true;
    programs.hyprland.package = pkgs.hyprland;
    programs.hyprland.withUWSM = true;
    #programs.dconf.enable = true;
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
        services.hyprpolkitagent.enable = true;
      };
  };
}
