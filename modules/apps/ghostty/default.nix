{
  lib,
  config,
  username,
  pkgs,
  ...
}:
let
  cfg = config.ghostty;
in
{
  options = {
    ghostty = {
      enable = lib.mkEnableOption "Enable ghostty in NixOS & home-manager";
    };
  };
  config = lib.mkIf cfg.enable {
    home-manager.users.${username} =
      { pkgs, config, ... }:
      {
        programs.ghostty = {
          enable = true;
          package = pkgs.ghostty-bin;
          settings = {
            gtk-single-instance = true;
          };
          enableZshIntegration = true;
          enableFishIntegration = true;
          enableBashIntegration = true;
          settings = {
            theme = "dark:Xcode Dark hc,light:GitHub Light Default";
            font-size = 14;
            font-family = "JetBrainsMono NFM Medium";
            window-padding-x = 12;
            window-padding-y = 12;
            macos-icon = "custom";
            macos-custom-icon = "${pkgs.fetchurl {
              url = "https://github.com/lukejanicke/ghostty-app-icons/raw/refs/heads/main/icons/ghostty-original.icns";
              sha256 = "sha256-vBH4oZUpUvZemwzuPa5XEjp072mTFkNt17XDRnrqK6Q=";
            }}";
            keybind = [
              "ctrl+h=goto_split:left"
              "ctrl+l=goto_split:right"
            ];
          };
        };
      };
  };
}
