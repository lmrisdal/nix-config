{
  lib,
  config,
  username,
  ...
}:
let
  cfg = config.starship;
in
{
  options = {
    starship = {
      enable = lib.mkEnableOption "Enable starship in NixOS & home-manager";
    };
  };
  config = lib.mkIf cfg.enable {
    home-manager.users.${username} = {
      programs.starship = {
        enable = true;
        enableBashIntegration = true;
        enableNushellIntegration = true;
        enableZshIntegration = true;
      };
    };
  };
}
