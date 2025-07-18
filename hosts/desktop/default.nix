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
    # ./impermanence.nix
    # Profiles
    ../../modules
    # Plasma
    # ../../modules/desktop-environments/kde/plasma-manager/desktop.nix
  ];

  # Custom modules
  desktop.enable = true;
  # gaming.enable = true;
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
    # pipewire = {
    #   extraConfig = {
    #     pipewire = {
    #       "10-clock-rate" = {
    #         "context.properties" = {
    #           # To make DAC properly work
    #           "default.clock.allowed-rates" = [
    #             44100
    #             48000
    #             88200
    #             96000
    #             176400
    #             192000
    #           ];
    #           "default.clock.quantum" = 512;
    #           "default.clock.min-quantum" = 512;
    #           "default.clock.max-quantum" = 512;
    #         };
    #       };
    #       # Create mono-only microphone output
    #       # "10-loopback-mono-mic" = {
    #       #   "context.modules" = [
    #       #     {
    #       #       "name" = "libpipewire-module-loopback";
    #       #       "args" = {
    #       #         "node.description" = "Samson G-Track Pro [MONO]";
    #       #         "capture.props" = {
    #       #           "node.name" = "capture.mono-microphone";
    #       #           "audio.position" = [ "FL" ];
    #       #           "target.object" =
    #       #             "alsa_input.usb-Samson_Technologies_Samson_G-Track_Pro_D0B3381619112B00-00.analog-stereo";
    #       #           "stream.dont-remix" = true;
    #       #           "node.passive" = true;
    #       #         };
    #       #         "playback.props" = {
    #       #           "media.class" = "Audio/Source";
    #       #           "node.name" = "mono-microphone";
    #       #           "audio.position" = [ "MONO" ];
    #       #         };
    #       #       };
    #       #     }
    #       #   ];
    #       # };
    #     };
    #   };
    # };
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
          WAYLANDDRV_PRIMARY_MONITOR = "HDMI-1"; # https://reddit.com/r/linux_gaming/comments/1louxm2/fix_for_wine_wayland_using_wrong_monitor/
        };
      };
    };
}
