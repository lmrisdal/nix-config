{
  lib,
  config,
  pkgs,
  username,
  vars,
  ...
}:
let
  cfg = config.virtualization;
in
{
  options = {
    virtualization = {
      enable = lib.mkEnableOption "Enable virtualization in NixOS & home-manager";
    };
  };
  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        docker-compose
        podlet
      ];
    };
    virtualisation = {
      podman = {
        enable = true;
        autoPrune = {
          enable = true;
          dates = "weekly";
        };
        defaultNetwork.settings.dns_enabled = true;
        #dockerCompat = true;
        #dockerSocket.enable = true;
      };
    };

    users = {
      users = {
        ${username} = {
          extraGroups = [
            "docker"
            "podman"
          ];
        };
      };
    };
  };
}
