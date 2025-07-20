{
  lib,
  username,
  config,
  ...
}:
{
  imports = [
    # System
    ./disko.nix
    ./filesystems.nix
    ./impermanence.nix
    # Profiles
    ../../modules
    # Plasma
    # ../../modules/desktop-environments/kde/plasma-manager/desktop.nix
  ];

  # Custom modules
  desktop.enable = true;
  gaming.enable = true;
  # streamcontroller.enable = true;
  # vhs-decode.enable = true;

  boot = {
    initrd = {
      availableKernelModules = lib.mkDefault [
        "nvme"
        "xhci_pci"
        "thunderbolt"
        "ahci"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];
    };
    kernelModules = lib.mkDefault [
      "kvm-amd"
    ];
    kernelParams = lib.mkDefault [
      "amd_iommu=on"
      "amd_pstate=guided"
      "microcode.amd_sha_check=off"
    ];
    tmp.tmpfsSize = "100%";
  };

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware = {
    nvidia = {
      modesetting.enable = true;
      nvidiaPersistenced = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };
    cpu.amd.updateMicrocode = true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  networking.useDHCP = lib.mkDefault true;

  networking = {
    hostName = "nixos";
  };

  powerManagement.cpuFreqGovernor = "schedutil";

  services = {
    ucodenix = {
      enable = true;
      cpuModelId = "00B40F40";
    };
  };

  systemd = {
    services = {
      # NetworkManager-wait-online.wantedBy = lib.mkForce [ ];
      plymouth-quit-wait.enable = false;
    };
    targets = {
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
  };

  zramSwap = {
    enable = true;
  };

  home-manager.users.${username} =
    { pkgs, ... }:
    {
      home = {
        packages = with pkgs; [ ];
        sessionVariables = {
          WAYLANDDRV_PRIMARY_MONITOR = "HDMI-A-1"; # https://reddit.com/r/linux_gaming/comments/1louxm2/fix_for_wine_wayland_using_wrong_monitor/
        };
      };
    };
}
