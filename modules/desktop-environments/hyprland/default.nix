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
    # services.greetd = {
    #   enable = true;
    #   settings = {
    #     default_session = {
    #       command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --time-format '%I:%M %p | %a • %h | %F' --cmd Hyprland";
    #       user = "greeter";
    #     };
    #   };
    # };
    xdg.portal = {
      extraPortals = with pkgs; [
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
      # greetd.tuigreet
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
      swaynotificationcenter
      nwg-look
      rose-pine-cursor
      rose-pine-hyprcursor
      pw-volume
      custom-sddm-astronaut
      kdePackages.qtmultimedia
      grim
      slurp
    ];
    programs.hyprland.enable = true;
    programs.hyprland.withUWSM = true;
    programs.waybar.enable = true;
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";
    home-manager.users.${username} = {
      services.swayosd.enable = true;
      # wayland.windowManager.hyprland.enable = true;
    };
    services.keyd = {
      enable = false;
      keyboards = {
        default = {
          ids = [ "*" ]; # what goes into the [id] section, here we select all keyboard
          # extraConfig = builtins.readFile /home/deftdawg/source/meta-mac/keyd/kde-mac-keyboard.conf; # use includes when debugging, easier to edit in vscode
          extraConfig = ''
            [main]
            # Use the 'leftmeta' key as the new "Cmd" key, activating the 'meta_mac' layer
            leftmeta = layer(meta_mac)
            rightmeta = rightalt

            # Optional: Ensure 'leftalt' retains its default behavior (usually not necessary)
            # leftalt = leftalt

            # The 'meta_mac' modifier layer; inherits from the 'Ctrl' modifier layer
            [meta_mac:C]
            # Copy
            c = C-insert
            # Paste
            v = S-insert
            # Cut
            x = S-delete
            # Move cursor to the beginning of the line
            left = home
            # Move cursor to the end of the line
            right = end

            # # As soon as 'tab' is pressed (but not yet released), switch to the 'app_switch_state' overlay
            # # Send a 'M-tab' key tap before entering 'app_switch_state'
            # tab = swapm(app_switch_state, M-tab)

            # # 'app_switch_state' modifier layer; inherits from the 'Meta' modifier layer
            # [app_switch_state:M]

            # # Meta-Tab: Switch to the next application
            # tab = M-tab
            # right = M-tab
          '';
        };
      };
    };
  };
}
