{
  lib,
  config,
  services,
  username,
  defaultSession ? "plasma",
  pkgs,
  ...
}:
let
  cfg = config.plasma;
in
{
  options = {
    plasma = {
      enable = lib.mkEnableOption "Enable Plasma in NixOS";
    };
  };

  config = lib.mkIf cfg.enable {
    services.displayManager = {
      defaultSession = "${defaultSession}";
      autoLogin = {
        enable = true;
        user = username;
      };
      sddm = {
        enable = true;
        wayland.enable = true;
        wayland.compositorCommand = "kwin";
        autoLogin.relogin = false;
      };
    };
    services.desktopManager = {
      plasma6 = {
        enable = true;
      };
    };
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      elisa
    ];
    systemd.services.sddm-conf = {
      wantedBy = [ "multi-user.target" ];
      enable = true;
      description = "Move SDDM configuration to /etc/sddm.conf.d so that we can override it later if needed (e.g. for autologin)";
      serviceConfig = {
        User = "root";
        Group = "root";
      };
      script = ''
        #!/bin/sh
        mkdir -p /etc/sddm.conf.d
        chmod 777 /etc/sddm.conf.d
        cat /etc/sddm.conf > /etc/sddm.conf.d/10-system.conf
        rm /etc/sddm.conf
      '';
    };
    home-manager.users.${username} =
      { pkgs, config, ... }:
      {
        home = {
          file = {
            quick-extract = {
              enable = true;
              text = ''
                [Desktop Entry]
                Comment=Extracts files without asking for user input
                Exec=ark -ba %U
                GenericName=Extract files with Ark
                Icon=ark
                InitialPreference=3
                MimeType=application/x-deb;application/x-cd-image;application/x-bcpio;application/x-cpio;application/x-cpio-compressed;application/x-sv4cpio;application/x-sv4crc;application/x-rpm;application/x-compress;application/gzip;application/x-bzip;application/x-bzip2;application/x-lzma;application/x-xz;application/zlib;application/zstd;application/x-lz4;application/x-lzip;application/x-lrzip;application/x-lzop;application/x-source-rpm;application/vnd.debian.binary-package;application/vnd.efi.iso;application/vnd.ms-cab-compressed;application/x-xar;application/x-iso9660-appimage;application/x-archive;application/x-tar;application/x-compressed-tar;application/x-bzip-compressed-tar;application/x-bzip2-compressed-tar;application/x-tarz;application/x-xz-compressed-tar;application/x-lzma-compressed-tar;application/x-lzip-compressed-tar;application/x-tzo;application/x-lrzip-compressed-tar;application/x-lz4-compressed-tar;application/x-zstd-compressed-tar;application/x-7z-compressed;application/vnd.rar;application/zip;application/x-java-archive;application/x-lha;application/x-stuffit;application/x-arj;application/arj;
                Name=Quick Extract
                NoDisplay=false
                Path=
                StartupNotify=true
                StartupWMClass=ark
                Terminal=false
                TerminalOptions=
                Type=Application
                X-DocPath=ark/index.html
                X-KDE-SubstituteUID=false
                X-KDE-Username=
              '';
              target = "${config.xdg.dataHome}/applications/quick-extract.desktop";
            };
          };
        };
      };
  };
}
