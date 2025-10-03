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
        #!/usr/bin/env bash

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

          # Query monitor state
          state=$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -r ".[] | select(.name==\"$monitor\")")
          
          format=$(echo "$state" | ${pkgs.jq}/bin/jq -r ".currentFormat")
          
          ### HDR / SDR toggle (bitdepth + cm)
          if [[ "$format" == "XRGB8888" ]]; then
              ${pkgs.hyprland}/bin/hyprctl keyword "monitorv2[$monitor]:bitdepth" 10
              ${pkgs.hyprland}/bin/hyprctl keyword "monitorv2[$monitor]:cm" hdr
              ${pkgs.hyprland}/bin/hyprctl keyword "monitorv2[$monitor]:supports_wide_color" 1
              ${pkgs.hyprland}/bin/hyprctl keyword "monitorv2[$monitor]:supports_hdr" 1
              ${pkgs.hyprland}/bin/hyprctl keyword "monitorv2[$monitor]:sdrbrightness" hdr
              ${pkgs.hyprland}/bin/hyprctl keyword "monitorv2[$monitor]:sdrsaturation" hdr
              ${pkgs.hyprland}/bin/hyprctl keyword "monitorv2[$monitor]:sdr_min_luminance" 0.005
              ${pkgs.hyprland}/bin/hyprctl keyword "monitorv2[$monitor]:sdr_max_luminance" 200
              ${pkgs.hyprland}/bin/hyprctl keyword "monitorv2[$monitor]:min_luminance" 0
              ${pkgs.hyprland}/bin/hyprctl keyword "monitorv2[$monitor]:max_luminance" 1300
              ${pkgs.hyprland}/bin/hyprctl keyword "monitorv2[$monitor]:max_avg_luminance" 200
              ${pkgs.hyprland}/bin/hyprctl keyword "decoration:blur:enabled" true
          elif [[ "$format" == "XBGR2101010" ]]; then
              ${pkgs.hyprland}/bin/hyprctl keyword "monitorv2[$monitor]:bitdepth" 8
              ${pkgs.hyprland}/bin/hyprctl keyword "monitorv2[$monitor]:cm" srgb
              ${pkgs.hyprland}/bin/hyprctl keyword "monitorv2[$monitor]:supports_wide_color" 0
              ${pkgs.hyprland}/bin/hyprctl keyword "monitorv2[$monitor]:supports_hdr" 0
              ${pkgs.hyprland}/bin/hyprctl keyword "decoration:blur:enabled" true
          else
              echo "Unknown format: $format"
          fi

        else
          echo "HDR not supported on $monitor; no changes made."
        fi
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
      };
  };
}
