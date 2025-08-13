{
  lib,
  config,
  username,
  pkgs,
  ...
}:
let
  cfg = config.ghostty;
in
{
  options = {
    ghostty = {
      enable = lib.mkEnableOption "Enable ghostty in NixOS & home-manager";
    };
  };
  config = lib.mkIf cfg.enable {
    home-manager.users.${username} =
      { pkgs, config, ... }:
      {
        programs.ghostty = {
          enable = true;
          settings = {
            gtk-single-instance = true;
          };
          enableZshIntegration = true;
          enableFishIntegration = true;
          enableBashIntegration = true;
        };
      };
  };
}
