{
  lib,
  config,
  username,
  pkgs,
  ...
}:
let
  cfg = config.vicinae;
in
{
  options = {
    vicinae = {
      enable = lib.mkEnableOption "Enable Vicinae (Raycast-like launcher) in home-manager";
    };
  };
  config = lib.mkIf cfg.enable {
    home-manager.users.${username} = {
      services.vicinae = {
        enable = true; # default: true
        autoStart = true; # default: true
      };
    };
  };
}
