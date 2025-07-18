{ config, pkgs, ... }:
{
  # Bootloader.
  boot = {
    loader = {
      timeout = null;
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      # grub = {
      #   efiSupport = true;
      #   efiInstallAsRemovable = true;
      #   device = "nodev";
      #   useOSProber = true;
      #   gfxmodeEfi = "3840x2160x32,2560x1440x32,1920x1080x32,1280x800x32,1280x1024x24,1024x768x32,800x600x32,auto"; # for 4k: 3840x2160
      #   gfxmodeBios = "3840x2160x32,2560x1440x32,1920x1080x32,1280x800x32,1280x1024x24,1024x768x32,800x600x32,auto"; # for 4k: 3840x2160
      #   theme = pkgs.stdenv.mkDerivation {
      #     pname = "distro-grub-themes";
      #     version = "3.1";
      #     src = pkgs.fetchFromGitHub {
      #       owner = "AdisonCavani";
      #       repo = "distro-grub-themes";
      #       rev = "v3.1";
      #       hash = "sha256-ZcoGbbOMDDwjLhsvs77C7G7vINQnprdfI37a9ccrmPs=";
      #     };
      #     installPhase = "cp -r customize/nixos $out";
      #   };
      # };
    };
    supportedFilesystems = [
      "ntfs"
      "exfat"
      "ext4"
      "fat32"
      "btrfs"
    ];
    extraModulePackages = with config.boot.kernelPackages; [ xpadneo ];
    # connect xbox controller
    extraModprobeConfig = ''
      options bluetooth disable_ertm=Y
    '';
    # plymouth = {
    #   enable = true;
    #   theme = "rings";
    #   themePackages = with pkgs; [
    #     # By default we would install all themes
    #     (adi1090x-plymouth-themes.override {
    #       selected_themes = [ "rings" ];
    #     })
    #   ];
    # };
    # #Enable "Silent Boot"
    # consoleLogLevel = 0;
    # initrd.verbose = false;
    # kernelParams = [
    #   "quiet"
    #   "splash"
    #   "boot.shell_on_fail"
    #   "loglevel=3"
    #   "rd.systemd.show_status=false"
    #   "rd.udev.log_level=3"
    #   "udev.log_priority=3"
    # ];
  };
}
