{
  lib,
  pkgs,
  username,
  config,
  inputs,
  ...
}:
{
  imports = [
    ./apps.nix
  ];

  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  environment = {
    systemPackages = with pkgs; [
      eza # Ls
      mas # Mac App Store $ mas search <app>
      tldr # Help
      wget # Download
      nixfmt-rfc-style # Nix formatter
      whatsapp-for-mac
      dotnet-sdk
      raycast
      discord
      monitorcontrol
      rectangle
      spotify
      azure-functions-core-tools
      #azure-artifacts-credprovider
    ];
  };

  homebrew = {
    enable = true;
    onActivation = {
      upgrade = false;
      cleanup = "zap";
    };
    casks = [
      "linearmouse"
      "visual-studio-code"
      "1password"
      "zen"
      "pearcleaner"
      "redis-insight"
    ];
    masApps = {
      "1Password for Safari" = 1569813296;
      "Tailscale" = 1475387142;
      "Wireguard" = 1451685025;
    };
    brews = [
      "azure-cli"
    ];
  };

  nix = {
    package = pkgs.nix;
    gc = {
      automatic = true;
      interval.Day = 7;
      options = "--delete-older-than 7d";
    };
    extraOptions = ''
      auto-optimise-store = true
      experimental-features = nix-command flakes
    '';
  };
  nixpkgs.config.allowUnfree = true;

  home-manager.users.${username} =
    { config, pkgs, ... }:
    {
      home = {
        username = username;
        homeDirectory = lib.mkDefault "/Users/${username}";
        stateVersion = "25.05";
      };
    };
  security.pam.services.sudo_local.touchIdAuth = true;
  system = {
    primaryUser = "${username}";
    stateVersion = 6;
    activationScripts.postActivation.text = ''
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';
    defaults = {
      dock.autohide = false;
      dock.show-recents = false;
    };
  };
}

# sudo darwin-rebuild switch --flake ~/.config/nix-config
