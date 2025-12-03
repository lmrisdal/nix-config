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
      ollama-cuda
      lmstudio
    ];
    home-manager.users.${username} = { };
  };
}
