{
  lib,
  username,
  config,
  ...
}:

{
  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  environment = {
    variables = {
      EDITOR = "nano";
      VISUAL = "nano";
    };
    systemPackages = with pkgs; [
      eza # Ls
      git # Version Control
      mas # Mac App Store $ mas search <app>
      tldr # Help
      wget # Download
      zsh-powerlevel10k # Prompt
    ];
  };

  programs = {
    zsh.enable = true;
    direnv = {
      enable = true;
      loadInNixShell = true;
      nix-direnv.enable = true;
    };
  };

  homebrew = {
    enable = true;
    onActivation = {
      upgrade = false;
      cleanup = "zap";
    };
    casks = [
    ];
    masApps = {
      "1Password for Safari" = 1569813296;
    };
  };

  nix = {
    package = pkgs.nix;
    gc = {
      automatic = true;
      interval.Day = 7;
      options = "--delete-older-than 7d";
    };
    extraOptions = ''
      # auto-optimise-store = true
      experimental-features = nix-command flakes
    '';
  };

  home-manager.users.${username} = {
    home.stateVersion = "25.05";
  };

  system = {
    primaryUser = "${username}";
    stateVersion = 6;
  };
}
