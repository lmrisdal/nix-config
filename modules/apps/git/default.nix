{
  lib,
  config,
  pkgs,
  username,
  fullname,
  ...
}:
let
  cfg = config.git;
in
{
  options = {
    git = {
      enable = lib.mkEnableOption "Enable git in NixOS & home-manager";
    };
  };
  config = lib.mkIf cfg.enable {
    # programs.git = lib.mkIf (!pkgs.stdenv.isDarwin) {
    #   enable = true;
    #   package = pkgs.gitFull;
    # };
    home-manager.users.${username} =
      { config, pkgs, ... }:
      {
        programs.git = {
          enable = true;
          package = pkgs.gitAndTools.gitFull;
          userName = "${fullname}";
          userEmail = "larsrisdal@gmail.com";
        };
      };
  };
}
