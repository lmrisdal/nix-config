{
  lib,
  config,
  username,
  defaultSession,
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
    # kitty.enable = true;
    zen-browser.enable = true;
    walker.enable = true;

    # System
    base.enable = true;
    sddm.enable = true;
    plasma.enable = true;
    # office.enable = true;

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
      };
    };
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
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
      # power-profiles-daemon.enable = true;
      udisks2 = {
        enable = true;
      };
    };

    services.xserver.enable = true;
    services.libinput.enable = true;

    home-manager.users.${username} =
      {
        pkgs,
        vars,
        ...
      }:
      {
        home.packages = with pkgs; [
          vscode.fhs
          dotnetCorePackages.sdk_8_0_3xx
          nodejs_24
          discord
          gearlever
          libreoffice-qt
        ];
      };
  };
}
