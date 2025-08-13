{
  lib,
  config,
  username,
  ...
}:
let
  cfg = config.ulauncher;
in
{
  options = {
    ulauncher = {
      enable = lib.mkEnableOption "Enable ulauncher in NixOS & home-manager";
    };
  };
  config = lib.mkIf cfg.enable {
    home-manager.users.${username} =
      { pkgs, config, ... }:
      {
        home.packages = with pkgs; [
          ulauncher
        ];
        home.file = {
          ulauncher-autostart = {
            enable = true;
            text = ''
              [Desktop Entry]
              Name=ulauncher
              Comment=ulauncher Service
              Exec=ulauncher --hide-window
              StartupNotify=false
              Terminal=false
              Type=Application
            '';
            target = "${config.xdg.configHome}/autostart/ulauncher.desktop";
          };
        };
      };
  };
}
