{
  lib,
  config,
  services,
  username,
  defaultSession ? "gnome",
  pkgs,
  ...
}:
let
  cfg = config.gnome;
in
{
  options = {
    gnome = {
      enable = lib.mkEnableOption "Enable GNOME in NixOS";
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      desktopManager.gnome = {
        enable = true;
        extraGSettingsOverridePackages = [ pkgs.mutter ];
        extraGSettingsOverrides = ''
          [org.gnome.mutter]
          experimental-features=['scale-monitor-framebuffer']
        '';
      };

      # hosts/global/core/ssh.nix handles this
      gnome.gcr-ssh-agent.enable = false;

      # displayManager = {
      #   gdm = {
      #     enable = true;
      #     wayland = true;
      #   };
      #   defaultSession = "${defaultSession}";
      #   autoLogin = {
      #     enable = true;
      #     user = username;
      #   };
      # };
      displayManager = {
        defaultSession = "${defaultSession}";
        autoLogin = {
          enable = true;
          user = username;
        };
        sddm = {
          enable = true;
          wayland.enable = true;
          autoLogin.relogin = true;
        };
      };

      # Configure keyboard layout for Wayland
      # xserver = {
      #   enable = false;
      #   xkb = {
      #     layout = "us";
      #     variant = "";
      #   };
      # };

      udev.packages = with pkgs; [ gnome-settings-daemon ];
    };

    boot.kernelModules = [ "i2c-dev" ];
    services.udev.extraRules = ''
      KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
    '';

    #INFO: Fix for autoLogin
    # systemd.services."getty@tty1".enable = false;
    # systemd.services."autovt@tty1".enable = false;

    environment.systemPackages = with pkgs; [
      gnome-tweaks
      gnomeExtensions.appindicator
      gnomeExtensions.auto-accent-colour
      gnomeExtensions.blur-my-shell
      gnomeExtensions.control-monitor-brightness-and-volume-with-ddcutil
      gnomeExtensions.dash-in-panel
      gnomeExtensions.just-perfection
      gnomeExtensions.pano
      gnomeExtensions.arcmenu
      gnomeExtensions.desktop-icons-ng-ding
      gnomeExtensions.quick-settings-audio-devices-hider
      gnomeExtensions.quick-settings-audio-devices-renamer
      gnomeExtensions.undecorate
      gnomeExtensions.vitals
    ];

    ## Exclusions ##
    environment.gnome.excludePackages = (
      with pkgs;
      [
        atomix
        baobab
        # epiphany
        # evince
        geary
        gedit
        #gnome-console
        gnome-contacts
        gnome-maps
        gnome-music
        gnome-photos
        gnome-terminal
        gnome-tour
        gnome-user-docs
        gnomeExtensions.applications-menu
        gnomeExtensions.launch-new-instance
        gnomeExtensions.light-style
        gnomeExtensions.places-status-indicator
        gnomeExtensions.status-icons
        gnomeExtensions.system-monitor
        gnomeExtensions.window-list
        gnomeExtensions.windownavigator
        hitori
        iagno
        simple-scan
        tali
        yelp
      ]
    );
  };
}
