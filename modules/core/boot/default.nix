{
  pkgs,
  lib,
  config,
  username,
  ...
}:
{
  boot = {
    consoleLogLevel = 0;
    initrd = {
      systemd.enable = true; # Plymouth login screen
      verbose = false;
    };
    kernel = {
      sysctl = {
        "kernel.sysrq" = 4;
        "kernel.nmi_watchdog" = 0;
      };
    };
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    kernelParams = [
      "nowatchdog"
      "zswap.enabled=0"
      # Quiet boot
      "quiet"
      "splash" # Plymouth
      "loglevel=0"
      "rd.udev.log_level=3"
      "systemd.show_status=auto"
      "udev.log_priority=3"
      "vt.global_cursor_default=0"
    ];
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      systemd-boot = {
        configurationLimit = 5;
        enable = lib.mkForce false;
        # enable = true;
        editor = false;
        #edk2-uefi-shell.enable = true; # Needed to find the Windows efiDeviceHandle (map-c and e.g. ls HB0b:\ and look for 'Microsoft')
      };
      timeout = lib.mkDefault 0;
    };
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
    plymouth.enable = true;
    supportedFilesystems = [
      "btrfs"
      "cifs"
      "ext4"
      "fat"
      "ntfs"
      "nfs"
    ];
    extraModulePackages = with config.boot.kernelPackages; [ xpadneo ];
    # bluetooth disable_ertm=Y = connect xbox controller at boot
    extraModprobeConfig = ''
      options bluetooth disable_ertm=Y
      options hid_apple fnmode=2
    '';
  };
  environment.systemPackages = with pkgs; [
    sbctl
    efibootmgr
    (writeShellScriptBin "switch-to-windows11" ''
      #!/bin/bash
      yad --title="Reboot into Windows" \
          --button=Yes:0 --button=No:1 \
          --text="Do you want to reboot into Windows?" \
          --width=300 --center

      if [[ $? -eq 0 ]]; then
          if sudo set-windows-boot-priority; then
              systemctl reboot
          else
              yad --title="Error" --text="Failed to change boot priority." --button=OK
          fi
      fi
      #sudo set-windows-one-shot
      #systemctl reboot
    '')
    (writeShellScriptBin "set-windows-one-shot" ''
      #!/bin/bash
      sudo bootctl set-oneshot auto-windows
    '')
    (writeShellScriptBin "set-windows-boot-priority" ''
      #!/bin/bash
      sudo efibootmgr -o 0000,0005
    '')
  ];
  security.sudo.extraRules = [
    {
      users = [ username ];
      commands = [
        {
          command = "/run/current-system/sw/bin/set-windows-one-shot";
          options = [
            "SETENV"
            "NOPASSWD"
          ];
        }
        {
          command = "/run/current-system/sw/bin/set-windows-boot-priority";
          options = [
            "SETENV"
            "NOPASSWD"
          ];
        }
      ];
    }
  ];
  home-manager.users.${username} =
    { pkgs, config, ... }:
    {
      home = {
        file = {
          "${config.xdg.configHome}/icons/windows11.png" = {
            source = pkgs.fetchurl {
              url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/windows-11.png";
              sha256 = "sha256-7j2LhRqtEfxQTiWbdp6c2wKGWFlokwA4W4x49N8P7kI=";
            };
          };
        };
      };
      xdg.desktopEntries = {
        windows11 = {
          name = "Switch to Windows 11";
          genericName = "Switch to Windows 11";
          exec = "switch-to-windows11";
          terminal = false;
          icon = "${config.xdg.configHome}/icons/windows11.png";
        };
      };
    };
}
