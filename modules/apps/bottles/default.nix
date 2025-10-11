{
  lib,
  config,
  username,
  inputs,
  ...
}:
let
  cfg = config.bottles;
in
{
  options = {
    bottles = {
      enable = lib.mkEnableOption "Enable bottles in home-manager";
      enableFlatpak = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      enableNative = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    home-manager.users.${username} =
      { config, pkgs, ... }:
      {
        home.file = {
          wine-links-kron4ek-bottles = {
            enable = false;
            source = config.lib.file.mkOutOfStoreSymlink inputs.nix-gaming.packages.${pkgs.system}.wine-tkg;
            target = "${config.xdg.dataHome}/bottles/runners/kron4ek";
          };
          wine-links-kron4ek-bottles-flatpak = {
            enable = false;
            source = config.lib.file.mkOutOfStoreSymlink inputs.nix-gaming.packages.${pkgs.system}.wine-tkg;
            target = ".var/app/com.usebottles.bottles/data/bottles/runners/kron4ek";
          };
          wine-links-proton-cachyos-bottles = {
            enable = cfg.enableNative;
            source = config.lib.file.mkOutOfStoreSymlink "${
              inputs.chaotic.packages.${pkgs.system}.proton-cachyos_x86_64_v4
            }/bin";
            target = "${config.xdg.dataHome}/bottles/runners/proton-cachyos";
          };
          wine-links-proton-cachyos-flatpak-bottles = {
            enable = cfg.enableFlatpak;
            source = config.lib.file.mkOutOfStoreSymlink "${
              inputs.chaotic.packages.${pkgs.system}.proton-cachyos_x86_64_v4
            }/bin";
            target = ".var/app/com.usebottles.bottles/data/bottles/runners/proton-cachyos";
          };
          wine-links-protonge-bottles = {
            enable = cfg.enableNative;
            source = config.lib.file.mkOutOfStoreSymlink "${pkgs.proton-ge-bin.steamcompattool}";
            target = "${config.xdg.dataHome}/bottles/runners/proton-ge-bin";
          };
          wine-links-protonge-flatpak-bottles = {
            enable = cfg.enableFlatpak;
            source = config.lib.file.mkOutOfStoreSymlink "${pkgs.proton-ge-bin.steamcompattool}";
            target = ".var/app/com.usebottles.bottles/data/bottles/runners/proton-ge-bin";
          };
        };
        home.packages = lib.mkIf cfg.enableNative [
          (pkgs.bottles.override {
            removeWarningPopup = true;
          })
        ];
        services.flatpak = lib.mkIf cfg.enableFlatpak {
          overrides = {
            "com.usebottles.bottles" = {
              Context = {
                filesystems = [
                  "/run/media/${username}"
                  "${config.xdg.dataHome}/bottles"
                  "${config.xdg.dataHome}/Steam"
                  "${config.home.homeDirectory}/Games/Bottles"
                ];
              };
              Environment = {
                PROTON_ENABLE_WAYLAND = "1";
                PROTON_ENABLE_HDR = "1";
                PROTON_USE_NTSYNC = "1";
                PROTON_USE_WOW64 = "1";
                PULSE_SINK = "Game";
              };
              "Session Bus Policy" = {
                "org.freedesktop.Flatpak" = "talk";
              };
            };
          };
          packages = [
            "com.usebottles.bottles"
          ];
        };
        xdg = {
          desktopEntries = {
            "bottles" = lib.mkIf cfg.enableNative {
              name = "Bottles";
              comment = "Run Windows software";
              exec = "env PROTON_ENABLE_WAYLAND=1 PROTON_ENABLE_HDR=1 PROTON_USE_NTSYNC=1 PROTON_USE_WOW64=1 PULSE_SINK=Game bottles %u";
              terminal = false;
              icon = "com.usebottles.bottles";
              type = "Application";
              startupNotify = true;
              categories = [
                "Utility"
                "Game"
              ];
            };
          };
        };
      };
  };
}
