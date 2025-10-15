{
  lib,
  config,
  pkgs,
  username,
  ...
}:
let
  cfg = config.localsend;
  localsendNautilusExtension = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/yungwarlock/localsend-nautilus-extension/main/src/localsend_extension.py";
    sha256 = "sha256-VVoSxQBXqnDW4L27/wVrOJ+luPfB5ymPoKTJB+S3cv4=";
  };
in
{
  options = {
    localsend = {
      enable = lib.mkEnableOption "Enable LocalSend in home-manager";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.localsend = {
      enable = true;
      package = pkgs.localsend;
    };
    home-manager.users.${username} =
      {
        config,
        ...
      }:
      {
        home.file.".local/share/nautilus-python/extensions/localsend_extension.py".source =
          localsendNautilusExtension;
        home.file = {
          localsend-autostart = {
            enable = true;
            text = ''
              [Desktop Entry]
              Name=LocalSend
              Comment=LocalSend
              Exec=${pkgs.localsend}/bin/localsend_app --hidden
              StartupNotify=false
              Terminal=false
              Type=Application
            '';
            target = "${config.xdg.configHome}/autostart/localsend-autostart.desktop";
          };
        };
      };
  };
}
