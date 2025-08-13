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
    xdg.portal = {
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
    };
    services = {
      desktopManager.gnome = {
        enable = true;
        extraGSettingsOverridePackages = [ pkgs.mutter ];
        extraGSettingsOverrides = ''
          [org.gnome.mutter]
          experimental-features=['scale-monitor-framebuffer', 'variable-refresh-rate', 'xwayland-native-scaling']
        '';
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
      gnomeExtensions.blur-my-shell
      gnomeExtensions.control-monitor-brightness-and-volume-with-ddcutil
      gnomeExtensions.dash-in-panel
      gnomeExtensions.just-perfection
      gnomeExtensions.pano
      gnomeExtensions.arcmenu
      gnomeExtensions.quick-settings-audio-devices-hider
      gnomeExtensions.quick-settings-audio-devices-renamer
      gnomeExtensions.logo-menu
      gnomeExtensions.search-light
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

    # programs.dconf.profiles.user.databases = [
    #   {
    #     settings = {
    #       "org/gnome/mutter" = {
    #         experimental-features = [
    #           "scale-monitor-framebuffer" # Enables fractional scaling (125% 150% 175%)
    #           "variable-refresh-rate" # Enables Variable Refresh Rate (VRR) on compatible displays
    #           "xwayland-native-scaling" # Scales Xwayland applications to look crisp on HiDPI screens
    #         ];
    #       };
    #     };
    #   }
    # ];

    home-manager.users.${username} =
      { pkgs, config, ... }:
      {

        dconf.enable = true;
        dconf.settings = {
          "org/gnome/desktop/interface" = {
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
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/nautilus/"
            ];
          };
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/1password" = {
            name = "1Password";
            command = "1password --quick-access";
            binding = "<Ctrl><Shift>space";
          };
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/nautilus" = {
            name = "Nautilus";
            command = "nautilus";
            binding = "<Super>e";
          };
          "org/gnome/shell".enabled-extensions = [
            "appindicatorsupport@rgcjonas.gmail.com"
            "arcmenu@arcmenu.com"
            "blur-my-shell@aunetx"
            "dash-in-panel@fthx"
            "just-perfection-desktop@just-perfection"
            "monitor-brightness-volume@ailin.nemui"
            "pano@elhan.io"
            "quicksettings-audio-devices-hider@marcinjahn.com"
            "quicksettings-audio-devices-renamer@marcinjahn.com"
            "logomenu@aryan_k"
            "search-light@icedman.github.com"
          ];
        };
      };
  };
}
