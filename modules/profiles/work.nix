{
  inputs,
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  cfg = config.work;
in
{
  options = {
    work = {
      enable = lib.mkEnableOption "Enable Work module in NixOS";
    };
  };

  config = lib.mkIf cfg.enable {
    dotnet.enable = true;
    home-manager.users.${username} =
      {
        config,
        pkgs,
        vars,
        ...
      }:
      {
        home = {
          packages = with pkgs; [
            vscode.fhs
            nodejs_24
            teams-for-linux
            python313Packages.azure-multiapi-storage
            azure-cli
            postman
            pulumi-bin
            redisinsight
            jetbrains.rider
            dapr-cli
            extism-cli
            (pkgs.writeShellScriptBin "pulumi-env-dt" ''
              _pulumi_read() { tr -d '\n' < "$1"; }
              export AZURE_STORAGE_ACCOUNT="$(_pulumi_read ${
                config.sops.secrets."pulumi_dt_storage_account".path
              })"
              export AZURE_STORAGE_KEY="$(_pulumi_read ${config.sops.secrets."pulumi_dt_storage_key".path})"
              export PULUMI_CONFIG_PASSPHRASE="$(_pulumi_read ${config.sops.secrets."pulumi_dt_passphrase".path})"
              export ARM_SUBSCRIPTION_ID="$(_pulumi_read ${config.sops.secrets."pulumi_dt_subscription_id".path})"
              export PULUMI_BACKEND_URL="azblob://state"
              echo "Pulumi DT environment loaded (backend=$PULUMI_BACKEND_URL)"
            '')
            (pkgs.writeShellScriptBin "pulumi-env-qp" ''
              _pulumi_read() { tr -d '\n' < "$1"; }
              export AZURE_STORAGE_ACCOUNT="$(_pulumi_read ${
                config.sops.secrets."pulumi_qp_storage_account".path
              })"
              export AZURE_STORAGE_KEY="$(_pulumi_read ${config.sops.secrets."pulumi_qp_storage_key".path})"
              export PULUMI_CONFIG_PASSPHRASE="$(_pulumi_read ${config.sops.secrets."pulumi_qp_passphrase".path})"
              export ARM_SUBSCRIPTION_ID="$(_pulumi_read ${config.sops.secrets."pulumi_qp_subscription_id".path})"
              export PULUMI_BACKEND_URL="azblob://state"
              echo "Pulumi QP environment loaded (backend=$PULUMI_BACKEND_URL)"
            '')
          ];
        };
      };
  };
}
