{
  lib,
  config,
  username,
  pkgs,
  ...
}:
let
  cfg = config.coolercontrol;
in
{
  options = {
    coolercontrol = {
      enable = lib.mkEnableOption "Enable coolercontrol in home-manager";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.coolercontrol = {
      enable = true;
    };
    environment.systemPackages = with pkgs; [ liquidctl ];

    home-manager.users.${username} = { };
  };
}
