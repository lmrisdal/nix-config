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
    services.gvfs.enable = true;
    services.gnome.sushi.enable = true;
    programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = "kitty";
    };
    environment.systemPackages = with pkgs; [
      pyprland # plugin system
      hyprpicker # color picker
      hyprcursor # cursor format
      hyprpaper # wallpaper util
      swww # wallpaper util
      hyprshot # screenshot util
      satty # screenshot annotation
      xfce.mousepad # txt editor
      zathura # pdf viewer
      mpv # media player
      imv # image viewer
      blueberry # bluetooth
      bluetui # bluetooth tui
      pavucontrol # volume control
      wiremix # volume control
      nautilus # file manager
      code-nautilus # vscode integration
      nautilus-python # nautilus plugin support
      ddcutil # control monitor brightness
      brightnessctl # control monitor brightness
      kdePackages.xwaylandvideobridge
      gnome-control-center # env XDG_CURRENT_DESKTOP=GNOME gnome-control-center
      rose-pine-cursor
      rose-pine-hyprcursor
      yad # dialog utility
      wl-clipboard # clipboard utils
      socat # socket utility
      gnome-system-monitor # system monitor
      #wl-screenrec # screen recording https://github.com/russelltg/wl-screenrec/issues/95
      (pkgs.writeShellScriptBin "toggle-altwin" ''
        # Toggle Hyprland alt/win key swap (altwin:swap_lalt_lwin)
        set -euo pipefail
        if ! command -v hyprctl >/dev/null 2>&1; then
          echo "hyprctl not found in PATH" >&2
          exit 1
        fi
        output="$(hyprctl getoption input:kb_options 2>/dev/null || true)"
        if echo "$output" | grep -q 'str: *altwin:swap_lalt_lwin' && echo "$output" | grep -q 'set: *true'; then
          hyprctl keyword input:kb_options ""
          notify-send "Alt/Win swap disabled" -t 1000
        else
          hyprctl keyword input:kb_options "altwin:swap_lalt_lwin"
          notify-send "Alt/Win swap enabled" -t 1000
        fi
      '')
      (pkgs.writeShellScriptBin "hypr-toggle-hdr" ''
        monitor=$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -r ".[] | select(.focused==true).name")
        # Find the sysfs path to EDID dynamically under card*
        edid_path=""
        for card in /sys/class/drm/card*; do
          candidate="$card-$monitor/edid"
          if [ -f "$candidate" ]; then
            edid_path="$candidate"
            break
          fi
        done

        if [ -z "$edid_path" ]; then
          echo "EDID file not found for monitor $monitor under any card* directory."
          exit 1
        fi

        if ${pkgs.edid-decode}/bin/edid-decode < "$edid_path" | grep -q "HDR Static Metadata Data Block"; then
          echo "HDR support detected on $monitor"

          enable_hdr() {
            ${pkgs.hyprland}/bin/hyprctl --batch \
              "keyword monitorv2[$monitor]:bitdepth 10 ; \
              keyword monitorv2[$monitor]:cm hdr ; \
              keyword monitorv2[$monitor]:sdrbrightness 1 ; \
              keyword monitorv2[$monitor]:sdrsaturation 1 ; \
              keyword monitorv2[$monitor]:sdr_min_luminance 0.005 ; \
              keyword monitorv2[$monitor]:sdr_max_luminance 200 ; \
              keyword monitorv2[$monitor]:min_luminance 0.005 ; \
              keyword monitorv2[$monitor]:max_luminance 1200 ; \
              keyword monitorv2[$monitor]:max_avg_luminance 200 ; \
              keyword decoration:blur:enabled true"
          }

          disable_hdr() {
            ${pkgs.hyprland}/bin/hyprctl --batch \
              "keyword monitorv2[$monitor]:bitdepth 8 ; \
              keyword monitorv2[$monitor]:cm srgb ; \
              keyword decoration:blur:enabled true"
          }

          # Query monitor state
          state=$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -r ".[] | select(.name==\"$monitor\")")
          
          format=$(echo "$state" | ${pkgs.jq}/bin/jq -r ".currentFormat")
          
          override=$1 # "on", "off", or empty/other -> toggle fallback
          echo "override: '$override', current format: '$format'"

          case "$override" in
            on)
              enable_hdr
              exit 0
              ;;
            off)
              disable_hdr
              exit 0
              ;;
            *)
              if [[ "$format" == "XRGB8888" ]]; then
                enable_hdr
              elif [[ "$format" == "XBGR2101010" ]]; then
                disable_hdr
              else
                echo "Unknown format: $format"
                exit 1
              fi
              ;;
          esac

        else
          echo "HDR not supported on $monitor; no changes made."
        fi
      '')
      (pkgs.writeShellScriptBin "hypr-get-hdr-state" ''
        monitor=$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.focused==true).name')
        state=$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -r ".[] | select(.name==\"$monitor\")")
        format=$(echo "$state" | ${pkgs.jq}/bin/jq -r ".currentFormat")
        if [[ "$format" == "XBGR2101010" ]]; then
          echo 1 # HDR
        else
          echo 0 # SDR
        fi
      '')
      (pkgs.writeShellScriptBin "hypr-toggle-vrr" ''
        state_dir="/home/${username}/.local/state/hypr"
        state_file="$state_dir/vrr_enabled"
        mkdir -p "$state_dir"

        # Read current preference; default to 3 (auto)
        if [ -r "$state_file" ]; then
          current_vrr="$(cat "$state_file" 2>/dev/null || echo 3)"
        else
          current_vrr="3"
        fi

        monitor=$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.focused==true).name')
        override=$1  # "on" -> 3, "off" -> 0, empty/other -> toggle

        case "$override" in
          on)  target=3 ;;
          off) target=0 ;;
          *)   if [ "$current_vrr" = "3" ]; then target=0; else target=3; fi ;;
        esac

        ${pkgs.hyprland}/bin/hyprctl keyword "monitorv2[$monitor]:vrr" "$target"
        echo "$target" > "$state_file"

        if [ "$target" -eq 3 ]; then
          notify-send "VRR: auto (enabled)" -t 1500
        else
          notify-send "VRR: off" -t 1500
        fi
      '')
      (pkgs.writeShellScriptBin "hypr-set-resolution" ''
        monitor=$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.focused==true).name')
        width=$1
        height=$2
        refresh=$3
        if [ -z "$width" ] || [ -z "$height" ] || [ -z "$refresh" ]; then
          echo "Usage: hypr-set-resolution <width> <height> <refresh_rate>"
          exit 1
        fi
        ${pkgs.hyprland}/bin/hyprctl --batch \
          "keyword monitorv2[$monitor]:scale 1.0 ; \
          keyword monitorv2[$monitor]:mode ''${width}x''${height}@''${refresh}"
      '')
      (pkgs.writeShellScriptBin "hypr-reset-resolution" ''
        monitor=$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.focused==true).name')
        ${pkgs.hyprland}/bin/hyprctl keyword "monitorv2[$monitor]:mode" "3840x2160@240"
        ${pkgs.hyprland}/bin/hyprctl keyword "monitorv2[$monitor]:scale" 1.2
      '')
      (pkgs.writeShellScriptBin "hypr-set-scale" ''
        monitor=$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.focused==true).name')
        scale=$1
        if [ -z "$scale" ]; then
          echo "Usage: hypr-set-scale <scale_factor>"
          exit 1
        fi
        ${pkgs.hyprland}/bin/hyprctl keyword "monitorv2[$monitor]:scale" "$scale"
      '')
    ];
    programs.hyprland.enable = true;
    programs.hyprland.package = pkgs.hyprland;
    programs.hyprland.withUWSM = true;
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
        home.file = {
          ".config/hypr/xdph.conf" = lib.mkDefault {
            text = ''
              screencopy {
                max_fps = 60
                allow_token_by_default = true
                custom_picker_binary = hyprland-share-picker
              }
            '';
          };
        };
      };
  };
}
