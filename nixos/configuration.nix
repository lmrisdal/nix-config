# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  lib,
  pkgs,
  inputs,
  self,
  username,
  fullname,
  ...
}:
let
  scripts = pkgs.callPackage ../modules/scripts { };
in
{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ../modules/hardware/drives.nix
    ../modules/hardware/nvidia.nix
  ];

  nixpkgs.config.allowUnfree = true;

  nix = {
    # Nix Package Manager Settings
    settings = {
      auto-optimise-store = true;
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org/"
        "https://nix-gaming.cachix.org/"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      use-xdg-base-directories = false;
      warn-dirty = false;
      keep-outputs = true;
      keep-derivations = true;
    };
    gc = {
      # Garbage Collection
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    optimise.automatic = true;
    package = pkgs.nixVersions.stable;
  };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nb_NO.UTF-8";
    LC_IDENTIFICATION = "nb_NO.UTF-8";
    LC_MEASUREMENT = "nb_NO.UTF-8";
    LC_MONETARY = "nb_NO.UTF-8";
    LC_NAME = "nb_NO.UTF-8";
    LC_NUMERIC = "nb_NO.UTF-8";
    LC_PAPER = "nb_NO.UTF-8";
    LC_TELEPHONE = "nb_NO.UTF-8";
    LC_TIME = "nb_NO.UTF-8";
  };

  # services.flatpak.enable = true;
  services.hardware.bolt.enable = true;

  hardware.xone.enable = true; # support for the xbox controller USB dongle
  hardware.xpadneo.enable = true;
  hardware.bluetooth = {
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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "no";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "no";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    description = "${fullname}";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      vim
      wget
      unzip
      unrar
      jq
      ntfs3g
      nixfmt-rfc-style
      lact
      libdbusmenu
      wofi
      wmctrl
      fastfetch
      firefox
      # gearlever
      # mangohud
      # scripts.gamescope-session
      # scripts.steamos-session-select
      # scripts.steamos-select-branch
      # scripts.jupiter-biosupdate
    ];
  };

  systemd.packages = with pkgs; [
    lact
  ];
  systemd.services.lactd.wantedBy = [ "multi-user.target" ];

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "lars" ];
  };
  environment.etc = {
    "1password/custom_allowed_browsers" = {
      text = ''
        zen
      '';
      mode = "0755";
    };
  };

  # programs.steam = {
  #   enable = true;
  #   remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  #   dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  #   localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  #   gamescopeSession.enable = true;
  #   extraCompatPackages = [ pkgs.proton-ge-bin ];
  # };
  # programs.gamescope = {
  #   enable = true;
  #   capSysNice = true;
  # };

  programs.dconf.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };

  services.xserver.enable = true;
  services.desktopManager = {
    plasma6 = {
      enable = true;
    };
  };
  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "lars";
    defaultSession = "plasma"; # hyprland
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    gdm = {
      enable = false;
    };
    # sessionPackages = [
    #   (
    #     (pkgs.writeTextDir "share/wayland-sessions/steam.desktop" ''
    #       [Desktop Entry]
    #       Name=Steam (gamescope)
    #       Comment=A digital distribution platform
    #       Exec=gamescope-session
    #       Type=Application
    #     '').overrideAttrs
    #     (_: {
    #       passthru.providedSessions = [ "steam" ];
    #     })
    #   )
    # ];
  };
  # programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.kdePackages.ksshaskpass.out}/bin/ksshaskpass";

  services.gnome.gnome-keyring.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Default shell
  # programs.zsh.enable = true;
  # users.defaultUserShell = pkgs.zsh;

  fonts.packages = with pkgs.nerd-fonts; [
    jetbrains-mono
    fira-code
  ];

  # environment.sessionVariables = {
  #   # These are the defaults, and xdg.enable does set them, but due to load
  #   # order, they're not set before environment.variables are set, which could
  #   # cause race conditions.
  #   XDG_CACHE_HOME = "$HOME/.cache";
  #   XDG_CONFIG_HOME = "$HOME/.config";
  #   XDG_DATA_HOME = "$HOME/.local/share";
  #   XDG_BIN_HOME = "$HOME/.local/bin";
  # };


  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
    krunner
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
