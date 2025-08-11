{
  pkgs,
  lib,
  config,
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
      timeout = 4;
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
      options hid_apple fnmode=0
    '';
  };
  environment.systemPackages = with pkgs; [ sbctl ];
}
