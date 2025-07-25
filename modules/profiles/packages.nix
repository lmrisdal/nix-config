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
      enable = lib.mkEnableOption "Enable packages in home-manager";
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
        lib,
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
          podman-tui
          jq
          wget
          unzip
          unrar
          (_7zz.override { enableUnfree = true; })
          p7zip
          libnotify
          dig
          ### Ansible ###
          # ansible
          # ansible-language-server
          # ansible-lintx
        ];
      };
  };
}
