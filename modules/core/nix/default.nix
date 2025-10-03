{
  lib,
  config,
  username,
  vars,
  ...
}:
let
  cfg = config.nixConfig;
in
{
  options = {
    nixConfig = {
      enable = lib.mkEnableOption "Enable nix in NixOS & home-manager";
    };
  };
  config = lib.mkIf cfg.enable {
    documentation = {
      man = {
        generateCaches = true;
      };
    };
    nix = {
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
      optimise = {
        automatic = true;
        dates = [ "10:00" ];
      };
      settings = {
        auto-optimise-store = true;
        builders-use-substitutes = true;
        experimental-features = [
          "flakes"
          "nix-command"
        ];
        extra-substituters = [
          "https://nix-community.cachix.org"
          "https://nix-gaming.cachix.org/"
        ];
        extra-trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        ];
        download-buffer-size = 524288000;
        keep-derivations = true;
        keep-outputs = true;
        log-lines = lib.mkDefault 50;
        trusted-users = [
          "${username}"
          "@wheel"
        ];
        use-xdg-base-directories = false;
        warn-dirty = false;
      };
    };
    nixpkgs = {
      config = {
        allowBroken = false;
        allowUnfree = true;
      };
      overlays = [
        (import ../../../overlays/overlay.nix)
      ];
    };
    system = {
      autoUpgrade = {
        enable = if vars.desktop then false else true;
        allowReboot = if vars.desktop then false else true;
        dates = "04:00:00";
        rebootWindow = {
          lower = "04:00";
          upper = "06:00";
        };
      };
    };

    home-manager.users.${username} =
      { config, ... }:
      {
        home = {
          extraProfileCommands = ''
            export GPG_TTY=$(tty)
          '';
          sessionPath = [
            "${config.home.homeDirectory}/.bin"
            "${config.home.homeDirectory}/.local/bin"
          ];
          sessionVariables = {
            NIXOS_OZONE_WL = "1"; # Electron apps
            NIXPKGS_ALLOW_UNFREE = "1";
          };
        };
        nixpkgs = {
          config = {
            allowBroken = false;
            allowUnfree = true;
          };
          overlays = [
            (import ../../../overlays/overlay.nix)
          ];
        };
        xdg = {
          enable = true;
          autostart.enable = true;
          userDirs = {
            enable = true;
            createDirectories = true;
            templates = null;
            publicShare = null;
          };
        };
      };
  };
}
