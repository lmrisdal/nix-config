{
  lib,
  config,
  username,
  services,
  pkgs,
  ...
}:
let
  cfg = config.desktop;
in
{
  imports = [ ./base.nix ];

  options = {
    desktop = {
      enable = lib.mkEnableOption "Enable desktop in NixOS";
    };
  };
  config = lib.mkIf cfg.enable {
    # vscode.enable = true;
    kitty.enable = true;
    ghostty.enable = true;
    zen-browser.enable = true;
    ulauncher.enable = false;
    rofi.enable = true;
    artifacts-credprovider.enable = true;
    coolercontrol.enable = true;
    #vesktop.enable = true;
    vicinae.enable = true;
    wf-recorder.enable = true;

    # System
    base.enable = true;
    greetd.enable = true;
    sddm.enable = false;
    plasma.enable = false;
    hyprland.enable = true;
    gnome.enable = false;

    boot = {
      binfmt = {
        emulatedSystems = [
          "aarch64-linux"
        ];
      };
    };

    services.xserver.xkb = {
      layout = "no";
      variant = "";
    };
    services.hardware.bolt.enable = true; # Thunderbolt
    hardware = {
      bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings.General = {
          experimental = true; # show battery
          # https://www.reddit.com/r/NixOS/comments/1ch5d2p/comment/lkbabax/
          # for pairing bluetooth controller
          Privacy = "device";
          JustWorksRepairing = "always";
          Class = "0x000100";
          FastConnectable = true;
        };
      };
      enableAllFirmware = true;
      i2c.enable = true;
      graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          vaapiVdpau
          nvidia-vaapi-driver
        ];
      };
    };
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    programs.gnome-disks.enable = true;
    services = {
      btrfs = {
        autoScrub = {
          enable = true;
          interval = "weekly";
        };
      };
      devmon.enable = true;
      fwupd.enable = true;
      lact.enable = true;
      power-profiles-daemon.enable = false;
      udisks2 = {
        enable = true;
      };
    };

    services.xserver.enable = true;
    services.libinput = {
      enable = true;
      mouse = {
        scrollMethod = "button";
        scrollButton = 2;
      };
    };

    home-manager.users.${username} =
      {
        config,
        pkgs,
        vars,
        ...
      }:
      {
        home.packages = with pkgs; [
          vscode.fhs
          dotnetCorePackages.sdk_8_0_3xx
          nodejs_24
          gearlever
          libreoffice-qt
          rustdesk-flutter
          teams-for-linux
          emote
          google-chrome
          chromium
          python313Packages.azure-multiapi-storage
          azure-cli
          postman
          pulumi-bin
          redisinsight
          jetbrains.rider
          discord
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
}
