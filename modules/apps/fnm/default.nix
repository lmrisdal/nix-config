{
  lib,
  config,
  pkgs,
  username,
  ...
}:
let
  cfg = config.fnm;
in
{
  options = {
    fnm = {
      enable = lib.mkEnableOption "Enable fnm (Node Version Manager) in NixOS & home-manager";
    };
  };
  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        fnm
      ];
    };
    home-manager.users.${username} = {
      programs.zsh.initContent = ''
        eval "$(fnm env --use-on-cd --shell zsh)"
      '';
    };
  };
}
