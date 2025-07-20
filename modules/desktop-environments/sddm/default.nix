{
  lib,
  config,
  defaultSession,
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
      defaultSession = "${defaultSession}"; # hyprland
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };
  };
}
