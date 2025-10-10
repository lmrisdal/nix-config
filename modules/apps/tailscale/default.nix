{
  lib,
  config,
  username,
  pkgs,
  ...
}:
let
  cfg = config.tailscale;
in
{
  options = {
    tailscale = {
      enable = lib.mkEnableOption "Enable tailscale in NixOS & home-manager";
    };
  };
  config = lib.mkIf cfg.enable {
    services = {
      tailscale = {
        enable = true;
        openFirewall = true;
        extraSetFlags = [
          "--ssh"
          "--accept-routes"
        ];
        useRoutingFeatures = "both";
      };
    };
    environment.systemPackages = with pkgs; [
      (pkgs.writeShellScriptBin "toggle-tailscale" ''
        status=$(tailscale status | grep -o 'active')
        if [ "$status" = "active" ]; then
          tailscale down
          notify-send "Tailscale disconnected"
        else
          tailscale up
          notify-send "Tailscale connected"
        fi
      '')
    ];
    home-manager.users.${username} =
      {
        config,
        ...
      }:
      {
        home.packages = with pkgs; [
          trayscale
        ];
        home.file = {
          tailscale-systray = {
            enable = true;
            text = ''
              [Desktop Entry]
              Name=Tailscale
              Comment=Tailscale system tray
              Exec=tailscale systray
              StartupNotify=false
              Terminal=false
              Type=Application
            '';
            target = "${config.xdg.configHome}/autostart/tailscale-systray.desktop";
          };
        };
      };
  };
}
