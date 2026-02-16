{
  lib,
  username,
  inputs,
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
  ];

  # Custom modules
  desktop.enable = true;
  gaming.enable = true;
  work.enable = true;
  llm.enable = true;

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
    # kernelPackages = pkgs.linuxPackages_cachyos.cachyOverride { mArch = "ZEN4"; };
    # loader = {
    #   systemd-boot = {
    #     windows = {
    #       "11" = {
    #         title = "Windows 11";
    #         efiDeviceHandle = "HD0b";
    #         sortKey = "z_windows";
    #       };
    #     };
    #   };
    # };
    tmp.tmpfsSize = "100%";
    extraModprobeConfig =
      "options nvidia_modeset vblank_sem_control=0 nvidia "
      + lib.concatStringsSep " " [
        # nvidia assume that by default your CPU does not support PAT,
        # but this is effectively never the case in 2023
        "NVreg_UsePageAttributeTable=1"
        # This may be a noop, but it's somewhat uncertain
        "NVreg_EnablePCIeGen3=1"
        # This is sometimes needed for ddc/ci support, see
        # https://www.ddcutil.com/nvidia/
        #
        # Current monitor does not support it, but this is useful for
        # the future
        "NVreg_RegistryDwords=RMUseSwI2c=0x01;RMI2cSpeed=100"
        # When (if!) I get another nvidia GPU, check for resizeable bar
        # settings
        "NVreg_InitializeSystemMemoryAllocations=0"
        "NVreg_RegistryDwords=RMIntrLockingMode=1"
        #"NVreg_PreserveVideoMemoryAllocations=1" # not needed with modesetting = true
        "NVreg_TemporaryFilePath=/var/tmp"
      ];
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware = {
    nvidia = {
      modesetting.enable = true;
      nvidiaPersistenced = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = true;
      nvidiaSettings = true;
      # package = config.boot.kernelPackages.nvidiaPackages.beta;

      # only needed for 590.48.01
      package =
        let
          nvidia-fixed-pkgs = import inputs.nixpkgs-nvidia {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          fixedKernelPackages = nvidia-fixed-pkgs.linuxKernel.packagesFor config.boot.kernelPackages.kernel;
        in
        fixedKernelPackages.nvidiaPackages.beta;
    };
  };
  environment.sessionVariables = {
    # GSK_RENDERER = "ngl";
    GDK_GL = "gles";
    __GL_SHADER_DISK_CACHE_SIZE = "12000000000";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  networking.useDHCP = lib.mkDefault true;

  networking = {
    hostName = "nixos";
  };

  powerManagement.cpuFreqGovernor = "schedutil";

  hardware.cpu.amd.updateMicrocode = true;
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
    services."systemd-suspend" = {
      serviceConfig = {
        Environment = ''"SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=false"'';
      };
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
        sessionVariables = {
          WAYLANDDRV_PRIMARY_MONITOR = "HDMI-A-1"; # https://reddit.com/r/linux_gaming/comments/1louxm2/fix_for_wine_wayland_using_wrong_monitor/
        };
      };
    };
}
