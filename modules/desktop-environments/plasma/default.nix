{
  lib,
  config,
  defaultSession,
  services,
  pkgs,
  ...
}:
let
  cfg = config.plasma;
in
{
  options = {
    plasma = {
      enable = lib.mkEnableOption "Enable Plasma in NixOS";
    };
  };

  config = lib.mkIf cfg.enable {
    services.desktopManager = {
      plasma6 = {
        enable = true;
      };
    };
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      elisa
    ];
  };
}
