{
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  cfg = config.llm;
in
{
  options = {
    llm = {
      enable = lib.mkEnableOption "Enable LLM module in NixOS";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      lmstudio
    ];
    home-manager.users.${username} = { };
  };
}
