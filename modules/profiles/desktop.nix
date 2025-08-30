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
    vesktop.enable = true;
    vicinae.enable = true;

    # System
    base.enable = true;
    sddm.enable = true;
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
          azure-cli
          postman
          pulumi-bin
        ];
        xdg = {
          desktopEntries = lib.mkIf cfg.enable {
            servicebusexplorer = {
              name = "Service Bus Explorer";
              genericName = "Service Bus Explorer";
              exec = "nero-umu --prefix \"default\" .prefixes/nero-umu/default/drive_c/users/steamuser/AppData/Roaming/ServiceBusExplorer-6.1.2/ServiceBusExplorer.exe";
              terminal = false;
              categories = [
                "Application"
              ];
            };
          };
        };
      };
  };
}
