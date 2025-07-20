{
  lib,
  config,
  username,
  ...
}:
let
  cfg = config.walker;
in
{
  options = {
    walker = {
      enable = lib.mkEnableOption "Enable walker in NixOS & home-manager";
    };
  };
  config = lib.mkIf cfg.enable {
    home-manager.users.${username} =
      { pkgs, config, ... }:
      {
        home.packages = with pkgs; [
          walker
        ];
        home.file = {
          walker-autostart = {
            enable = true;
            text = ''
              [Desktop Entry]
              Name=Walker
              Comment=Walker Service
              Exec=walker --gapplication-service
              StartupNotify=false
              Terminal=false
              Type=Application
            '';
            target = "${config.xdg.configHome}/autostart/walker.desktop";
          };
        };
      };
  };
}
