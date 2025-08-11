{
  lib,
  config,
  username,
  pkgs,
  ...
}:
let
  cfg = config.rofi;
in
{
  options = {
    rofi = {
      enable = lib.mkEnableOption "Enable rofi in NixOS & home-manager";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      wmctrl
    ];
    home-manager.users.${username} =
      { pkgs, config, ... }:
      {
        programs.rofi = {
          enable = true;
          package = pkgs.rofi-wayland;
          location = "center";
          theme = "arthur";
          plugins = with pkgs; [
            rofi-emoji
            rofi-calc
          ];
        };
      };
  };
}
