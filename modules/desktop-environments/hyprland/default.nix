{
  lib,
  config,
  pkgs,
  username,
  defaultSession,
  ...
}:
let
  cfg = config.hyprland;
  custom-sddm-astronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = "jake_the_dog";
    themeConfig = {
      AllowUppercaseLettersInUsernames = "true";
    };
  };
in
{
  options = {
    hyprland = {
      enable = lib.mkEnableOption "Enable Hyprland in NixOS";
    };
  };
  config = lib.mkIf cfg.enable {
    hyprpanel.enable = true;

    xdg.portal = {
      extraPortals = with pkgs; [
        xdg-desktop-portal
        xdg-desktop-portal-hyprland
      ];
    };
    services.displayManager = {
      defaultSession = "${defaultSession}";
      autoLogin = {
        enable = true;
        user = username;
      };
      sddm = {
        enable = true;
        wayland.enable = true;
        package = pkgs.kdePackages.sddm;
        enableHidpi = true;
        theme = "sddm-astronaut-theme";
        settings = {
          Theme = {
            Current = "sddm-astronaut-theme";
            CursorTheme = "rose-pine-cursor";
            CursorSize = 24;
            Font = "SF Pro";
          };
        };
        extraPackages = with pkgs; [
          custom-sddm-astronaut
        ];
        autoLogin.relogin = false;
      };
    };
    services.dbus.enable = true;
    services.playerctld.enable = true;
    environment.systemPackages = with pkgs; [
      pyprland # plugin system
      hyprpicker # color picker
      hyprcursor # cursor format
      hyprlock # lock screen
      hyprpolkitagent # polkit agent
      hypridle # idle daemon
      hyprpaper # wallpaper util
      swww # wallpaper util
      hyprshot # screenshot util
      helix # txt editor
      zathura # pdf viewer
      mpv # media player
      imv # image viewer
      overskride # bluetooth
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
      pw-volume
      custom-sddm-astronaut
      kdePackages.qtmultimedia
      grim
      slurp
      networkmanagerapplet
    ];
    programs.hyprland.enable = true;
    programs.hyprland.package = pkgs.hyprland;
    programs.hyprland.withUWSM = true;
    #programs.waybar.enable = true;
    programs.dconf.enable = true;
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";
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
    home-manager.users.${username} =
      {
        inputs,
        config,
        ...
      }:
      {
        gtk = {
          enable = true;
        };
        services.swayosd.enable = true;
        programs.wlogout = {
          enable = true;
          layout = [
            {
              label = "logout";
              action = "loginctl kill-user $(whoami)";
              text = "Logout";
              # keybind = "l";
            }
            {
              label = "lock";
              action = "hyprlock";
              text = "Lock";
              # keybind = "x";
            }
            {
              label = "sleep";
              action = "systemctl suspend";
              text = "Sleep";
              # keybind = "s";
            }
            {
              label = "reboot";
              action = "systemctl reboot";
              text = "Reboot";
              # keybind = "r";
            }
            {
              label = "shutdown";
              action = "shutdown now";
              text = "Shutdown";
              # keybind = "p";
            }
          ];
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
