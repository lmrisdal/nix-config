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
    home-manager.users.${username} = {
      home.packages = with pkgs; [ ktailctl ];
      xdg.autostart.entries = with pkgs; [
        "${ktailctl}/share/applications/org.fkoehler.KTailctl.desktop"
      ];
    };
  };
}
