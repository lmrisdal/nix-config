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
        home.file = {
          "${config.xdg.configHome}/rofi/themes/spotlight-dark.rasi" = {
            source = pkgs.fetchurl {
              url = "https://raw.githubusercontent.com/newmanls/rofi-themes-collection/refs/heads/master/themes/spotlight-dark.rasi";
              sha256 = "sha256-z+ZM0oTo2Lym0a4xReAPArdQKtpwPk9FDMnuCh57ZMI=";
            };
          };
        };
        programs.rofi = {
          enable = true;
          package = pkgs.rofi;
          location = "center";
          theme = "${config.xdg.configHome}/rofi/themes/spotlight-dark.rasi";
          terminal = "kitty";
          plugins = with pkgs; [
            rofi-emoji
            rofi-calc
          ];
        };
      };
  };
}
