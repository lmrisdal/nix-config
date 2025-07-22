{
  lib,
  config,
  defaultSession,
  username,
  services,
  ...
}:
let
  cfg = config.sddm;
in
{
  options = {
    sddm = {
      enable = lib.mkEnableOption "Enable SDDM in NixOS";
    };
  };

  config = lib.mkIf cfg.enable {
    services.displayManager = {
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
  };
}
