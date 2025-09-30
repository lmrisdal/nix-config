{
  lib,
  config,
  username,
  pkgs,
  ...
}:
let
  cfg = config.secrets;
in
{
  options = {
    secrets = {
      enable = lib.mkEnableOption "Enable secrets in NixOS & home-manager";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ssh-to-age
      sops
    ];
    sops = {
      # age.keyFile = "/etc/sops/age/keys.txt";
      age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
      defaultSopsFile = ./secrets.yaml;
      defaultSopsFormat = "yaml";
    };
    home-manager.users.${username} =
      { config, ... }:
      {
        sops = {
          age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
          defaultSopsFile = ./secrets.yaml;
          defaultSopsFormat = "yaml";
          secrets."weather.json" = { };
          secrets."pulumi_dt_storage_account" = { };
          secrets."pulumi_dt_storage_key" = { };
          secrets."pulumi_dt_passphrase" = { };
          secrets."pulumi_dt_subscription_id" = { };
          secrets."pulumi_qp_storage_account" = { };
          secrets."pulumi_qp_storage_key" = { };
          secrets."pulumi_qp_passphrase" = { };
          secrets."pulumi_qp_subscription_id" = { };
        };
      };
  };
}
