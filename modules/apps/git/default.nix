{
  lib,
  config,
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
      enable = lib.mkEnableOption "Enable git in home-manager";
    };
  };
  config = lib.mkIf cfg.enable {
    home-manager.users.${username} =
      { config, pkgs, ... }:
      {
        programs.git = {
          enable = true;
          settings = {
            user.email = "larsrisdal@gmail.com";
            user.name = "${fullname}";
          };
        };
      };
  };
}
