{
  inputs,
  lib,
  config,
  pkgs,
  username,
  ...
}:
{
  # You can import other home-manager modules here
  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  # nixpkgs = {
  #   overlays = [];
  #   config = {
  #     allowUnfree = true;
  #     allowUnfreePredicate = _: true;
  #   };
  # };

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
  };

  home.packages = with pkgs; [
    vscode.fhs
    # dotnetCorePackages.sdk_8_0_3xx
    # nodejs
    spotify
    discord
    # vlc
    # mangohud
    # wineWowPackages.staging
    # lutris
    # bottles
    # heroic
    # nix-prefetch-scripts
    # dconf2nix
    # krita
    # kde-rounded-corners
    # rustdesk-flutter
  ];

  home.file = {
    ".config/autostart/1password.desktop".text = ''
      [Desktop Entry]
      Name=1Password
      Exec=1password --silent
      Icon=1password
      Terminal=false
      Type=Application
    '';
  };
  # home.file = {
  #   ".config/autostart/steam.desktop".text = ''
  #     [Desktop Entry]
  #     Name=Steam
  #     Exec=steam -silent
  #     Icon=steam
  #     Terminal=false
  #     Type=Application
  #     MimeType=x-scheme-handler/steam;x-scheme-handler/steamlink;
  #     Actions=Store;Community;Library;Servers;Screenshots;News;Settings;BigPicture;Friends;
  #     PrefersNonDefaultGPU=true
  #     X-KDE-RunOnDiscreteGpu=true
  #   '';
  # };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git = {
    package = pkgs.gitAndTools.gitFull;
    enable = true;
    userName = "Lars Risdal";
    userEmail = "larsrisdal@gmail.com";
  };

  programs.zen-browser = {
    enable = true;
    nativeMessagingHosts = [ pkgs.firefoxpwa ];
    policies = {
      AutofillAddressEnabled = true;
      AutofillCreditCardEnabled = false;
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true; # save webs for later reading
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4531307/ublock_origin-1.65.0.xpi";
          installation_mode = "force_installed";
        };
      };
      Preferences =
        let
          locked = value: {
            "Value" = value;
            "Status" = "locked";
          };
        in
        {
          "browser.tabs.warnOnClose" = locked false;
        };
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.05";
}
