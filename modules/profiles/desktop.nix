{
  lib,
  config,
  username,
  services,
  pkgs,
  ...
}:
let
  cfg = config.desktop;
in
{
  imports = [ ./base.nix ];

  options = {
    desktop = {
      enable = lib.mkEnableOption "Enable desktop in NixOS";
    };
  };
  config = lib.mkIf cfg.enable {
    # Custom modules
    # Apps
    # easyeffects.enable = true;
    # mumble.enable = true;
    # rmpc.enable = true;
    # vesktop.enable = true;
    # vscode.enable = true;
    # wezterm.enable = true;
    # wireshark.enable = true;
    zen-browser.enable = true;

    # System
    base.enable = true;
    # catppuccinTheming.enable = true;
    # kde.enable = true;
    # office.enable = true;

    boot = {
      binfmt = {
        emulatedSystems = [
          "aarch64-linux"
        ];
      };
    };

    services.xserver.xkb = {
      layout = "no";
      variant = "";
    };
    services.hardware.bolt.enable = true; # Thunderbolt
    hardware = {
      bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings.General = {
          experimental = true; # show battery
          # https://www.reddit.com/r/NixOS/comments/1ch5d2p/comment/lkbabax/
          # for pairing bluetooth controller
          Privacy = "device";
          JustWorksRepairing = "always";
          Class = "0x000100";
          FastConnectable = true;
        };
      };
      enableAllFirmware = true;
      i2c.enable = true;
      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    services = {
      btrfs = {
        autoScrub = {
          enable = true;
          interval = "weekly";
        };
      };
      devmon.enable = true;
      fwupd.enable = true;
      lact.enable = true;
      # power-profiles-daemon.enable = true;
      udisks2 = {
        enable = true;
      };
    };

    services.xserver.enable = true;
    services.desktopManager = {
      plasma6 = {
        enable = true;
      };
    };
    services.displayManager = {
      # autoLogin.enable = true;
      autoLogin.user = "lars";
      defaultSession = "plasma"; # hyprland
      sddm = {
        enable = true;
        wayland.enable = true;
        autoLogin.relogin = true;
        settings = {
          Autologin = {
            Session = "plasma.desktop";
          };
        };
      };
      gdm = {
        enable = false;
      };
      sessionPackages = [
        (
          (pkgs.writeTextDir "share/wayland-sessions/steam.desktop" ''
            [Desktop Entry]
            Name=Steam (gamescope)
            Comment=A digital distribution platform
            Exec=gamescope-session
            Type=Application
          '').overrideAttrs
          (_: {
            passthru.providedSessions = [ "steam" ];
          })
        )
      ];
    };
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      elisa
    ];
    # programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.kdePackages.ksshaskpass.out}/bin/ksshaskpass";
    # services.gnome.gnome-keyring.enable = true;
    services.libinput.enable = true;

    home-manager.users.${username} =
      {
        pkgs,
        vars,
        ...
      }:
      {
        home.packages = with pkgs; [
          vscode.fhs
          dotnetCorePackages.sdk_8_0_3xx
          nodejs
          #spotify
          discord
          gearlever
          warp-terminal
        ];
        # mimeApps =
        #   let
        #     audioPlayer = "org.fooyin.fooyin.desktop";
        #     browser = "app.zen_browser.zen.desktop";
        #     editor = "org.kde.kate.desktop";
        #     imageViewer = "org.kde.gwenview.desktop";
        #     pdfViewer = "org.kde.okular.desktop";
        #     videoPlayer = "org.kde.haruna.desktop";
        #   in
        #   {
        #     enable = true;
        #     defaultApplications =
        #       {
        #         "audio/*" = audioPlayer;
        #         "image/*" = imageViewer;
        #         "video/*" = videoPlayer;
        #         "text/*" = editor;
        #         "text/html" = browser;
        #         "text/plain" = editor;
        #         "application/json" = editor;
        #         "application/pdf" = pdfViewer;
        #         "application/toml" = editor;
        #         "application/x-bat" = editor;
        #         "application/xhtml+xml" = browser;
        #         "application/xml" = editor;
        #         "application/x-shellscript" = editor;
        #         "application/x-yaml" = editor;
        #         "inode/directory" = "org.kde.dolphin.desktop";
        #         "x-scheme-handler/bottles" = "com.usebottles.bottles.desktop";
        #         "x-scheme-handler/http" = browser;
        #         "x-scheme-handler/https" = browser;
        #         "x-scheme-handler/sgnl" = "signal.desktop";
        #         "x-scheme-handler/signalcaptcha" = "signal.desktop";
        #         "x-scheme-handler/terminal" = "org.wezfurlong.wezterm.desktop";
        #       }
        #       // lib.optionalAttrs vars.gaming {
        #         "application/x-alcohol" = "cdemu-client.desktop";
        #         "application/x-cue" = "cdemu-client.desktop";
        #         "application/x-gd-rom-cue" = "cdemu-client.desktop";
        #         "application/x-msdownload" = "wine.desktop";
        #         "x-scheme-handler/ror2mm" = "r2modman.desktop";
        #       };
        #   };
        # portal = {
        #   config.common.default = "*";
        #   enable = true;
        #   extraPortals = with pkgs; [
        #     kdePackages.xdg-desktop-portal-kde
        #     xdg-desktop-portal-gtk
        #   ];
        # };
      };
  };
}
