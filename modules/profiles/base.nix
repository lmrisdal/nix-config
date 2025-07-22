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
    # Custom modules
    # Apps
    onepassword.enable = true;
    # atuin.enable = true;
    # bash.enable = true;
    # bat.enable = true;
    # boxxy.enable = true;
    # btop.enable = true;
    direnv.enable = true;
    # distrobox.enable = true;
    fastfetch.enable = true;
    # fd.enable = true;
    fzf.enable = true;
    git.enable = true;
    # gpg.enable = true;
    # helix.enable = true;
    home-managerConfig.enable = true;
    # jujutsu.enable = true;
    # keyd.enable = false;
    # lazydocker.enable = true;
    # lazygit.enable = true;
    # lazysql.enable = true;
    # lsd.enable = true;
    # mullvad.enable = true;
    # navi.enable = true;
    # nh.enable = true;
    # nix-ld.enable = true;
    # nix-index.enable = true;
    # nushell.enable = true;
    # nvim.enable = true;
    # pay-respects.enable = true;
    # rclone.enable = true;
    # ripgrep.enable = true;
    ssh.enable = true;
    starship.enable = true;
    # tailscale.enable = true;
    # tealdeer.enable = true;
    # television.enable = true;
    # topgrade.enable = true;
    # yazi.enable = true;
    # yt-dlp.enable = true;
    # zoxide.enable = true;
    zsh.enable = true;
    spotify.enable = true;

    # System
    flatpak.enable = true;
    # fonts.enable = true;
    # hardening.enable = true;
    mounts.enable = true;
    networking.enable = true;
    nixConfig.enable = true;
    # packages.enable = true;
    pipewire.enable = true;
    # secrets.enable = true;
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
        wget
        unzip
        unrar
        jq
        ntfs3g
        nixfmt-rfc-style
        libdbusmenu
        wofi
        wmctrl
        firefox
        (pkgs.writeShellScriptBin "nixswitch" ''
          #!/bin/bash
          # Run the NixOS rebuild switch command with the provided arguments
          sudo nixos-rebuild switch --flake ~/.config/nix-config/
        '')
        (pkgs.writeShellScriptBin "nixtest" ''
          #!/bin/bash
          # Run the NixOS rebuild test command with the provided arguments
          sudo nixos-rebuild test --flake ~/.config/nix-config/
        '')
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
