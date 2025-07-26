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
      };

      gnome.gcr-ssh-agent.enable = false;
      gnome.gnome-keyring.enable = true;

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

      udev.packages = with pkgs; [ gnome-settings-daemon ];
    };

    security.pam.services = {
      greetd.enableGnomeKeyring = true;
      login.enableGnomeKeyring = true;
      sddm.enableGnomeKeyring = true;
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

    programs.dconf.profiles.user.databases = [
      {
        settings = {
          "org/gnome/mutter" = {
            experimental-features = [
              "scale-monitor-framebuffer" # Enables fractional scaling (125% 150% 175%)
              "variable-refresh-rate" # Enables Variable Refresh Rate (VRR) on compatible displays
              "xwayland-native-scaling" # Scales Xwayland applications to look crisp on HiDPI screens
            ];
          };
        };
      }
    ];

    home-manager.users.${username} =
      { pkgs, config, ... }:
      {
        dconf.enable = true;
        dconf.settings = {
          "org/gnome/desktop/interface" = {
            accent-color = "blue";
          };
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
            enable-hot-corners = false;
            clock-show-weekday = true;
          };
          "org/gnome/desktop/wm/preferences" = {
            mouse-button-modifier = "<Alt>";
            resize-with-right-button = true;
          };
          "org/gnome/settings-daemon/plugins/media-keys" = {
            custom-keybindings = [
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/1password/"
            ];
          };
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/1password" = {
            name = "1Password";
            command = "1password --quick-access";
            binding = "<Ctrl><Shift>space";
          };
        };
      };
  };
}
