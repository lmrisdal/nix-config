{
  lib,
  config,
  pkgs,
  username,
  vars,
  ...
}:
let
  cfg = config.base;
in
{
  options = {
    base = {
      enable = lib.mkEnableOption "Enable base in NixOS";
    };
  };
  config = lib.mkIf cfg.enable {
    # Apps
    onepassword.enable = true;
    direnv.enable = true;
    fastfetch.enable = true;
    fd.enable = true;
    fzf.enable = true;
    git.enable = true;
    gpg.enable = true;
    home-managerConfig.enable = true;
    keyd.enable = false;
    nix-index.enable = true;
    ssh.enable = true;
    starship.enable = true;
    tailscale.enable = true;
    zoxide.enable = true;
    zsh.enable = true;
    spotify.enable = true;

    # System
    flatpak.enable = true;
    fonts.enable = true;
    mounts.enable = true;
    networking.enable = true;
    nixConfig.enable = true;
    packages.enable = true;
    pipewire.enable = true;
    users.enable = true;
    virtualization.enable = true;

    console = {
      earlySetup = true;
      keyMap = "no";
    };
    environment = {
      homeBinInPath = true;
      localBinInPath = true;
      shells = with pkgs; [
        bash
        zsh
      ];
      stub-ld.enable = true;
      systemPackages = with pkgs; [
        lm_sensors
        pciutils
        xdg-dbus-proxy
        xdg-user-dirs
        ntfs3g
        nixfmt-rfc-style
        libdbusmenu
        edid-decode
        lsof
      ];
    };

    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
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
    };

    services = {
      cron.enable = true;
      dbus.implementation = "broker";
      earlyoom = {
        enable = true;
        freeMemThreshold = 5;
        enableNotifications = if vars.desktop then true else false;
      };
      fstrim.enable = true;
      journald = {
        extraConfig = ''
          SystemMaxUse=50M
        '';
      };
      logrotate.enable = true;
    };

    systemd = {
      extraConfig = ''
        DefaultTimeoutStartSec=15s
        DefaultTimeoutStopSec=10s
      '';
    };

    system.stateVersion = "25.05";

    time.timeZone = "Europe/Oslo";

    home-manager.users.${username} =
      { lib, username, ... }:
      {
        home = {
          username = username;
          homeDirectory = lib.mkDefault "/home/${username}";
          stateVersion = "25.05";
        };
      };
  };
}
