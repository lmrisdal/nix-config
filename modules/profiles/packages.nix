{
  lib,
  inputs,
  config,
  username,
  pkgs,
  ...
}:
let
  cfg = config.packages;
in
{
  options = {
    packages = {
      enable = lib.mkEnableOption "Enable misc NixOS and Home Manager packages";
    };
  };
  config = lib.mkIf cfg.enable {
    environment = {
      etc."packages".text =
        let
          packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
          sortedUnique = builtins.sort builtins.lessThan (pkgs.lib.lists.unique packages);
          formatted = builtins.concatStringsSep "\n" sortedUnique;
        in
        formatted;
      systemPackages = with pkgs; [
        lm_sensors
        pciutils
        xdg-dbus-proxy
        xdg-user-dirs
        ntfs3g
        nixfmt-rfc-style
        nixd
        nil
        libdbusmenu
        edid-decode
        lsof
        killall
        btop
        cmatrix
        inputs.nix-gaming.packages.${system}.wine-tkg
      ];
    };
    programs = {
      appimage = {
        enable = true;
        binfmt = true;
      };
      iotop = {
        enable = true;
      };
    };
    home-manager.users.${username} =
      {
        pkgs,
        config,
        ...
      }:
      {
        home.file = {
          current-packages = {
            enable = true;
            text =
              let
                packages = builtins.map (p: "${p.name}") config.home.packages;
                sortedUnique = builtins.sort builtins.lessThan (pkgs.lib.lists.unique packages);
                formatted-hm = builtins.concatStringsSep "\n" sortedUnique;
              in
              formatted-hm;
            target = "${config.xdg.configHome}/packages-hm";
          };
        };
        home.packages = with pkgs; [
          eza
          jq
          wget
          unzip
          unrar
          (_7zz.override { enableUnfree = true; })
          p7zip
          libnotify
          dig
          #darktable
        ];
      };
  };
}
