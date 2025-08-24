{
  config,
  nixosConfig,
  lib,
  pkgs,
  username,
  ...
}:
with lib;
let
  cfg = config.vicinae;
  vicinae = pkgs.stdenv.mkDerivation rec {
    pname = "vicinae";
    version = "0.6.2";

    src = pkgs.fetchurl {
      url = "https://github.com/vicinaehq/vicinae/releases/download/v${version}/vicinae-linux-x86_64-v${version}.tar.gz";
      sha256 = "sha256-+lTnWBMoZ1OYZNTanyW8JajEj8WFBskB3WJpkM/uwtE=";
    };

    nativeBuildInputs = with pkgs; [
      autoPatchelfHook
      qt6.wrapQtAppsHook
    ];
    buildInputs = with pkgs; [
      qt6.qtbase
      qt6.qtsvg
      qt6.qttools
      qt6.qtwayland
      qt6.qtdeclarative
      qt6.qt5compat
      kdePackages.qtkeychain
      kdePackages.layer-shell-qt
      openssl
      cmark-gfm
      libqalculate
      minizip
      stdenv.cc.cc.lib
      abseil-cpp
      protobuf
      nodejs
      wayland
    ];

    unpackPhase = ''
      tar -xzf $src
    '';

    installPhase = ''
      mkdir -p $out/bin $out/share/applications
      cp bin/vicinae $out/bin/
      cp share/applications/vicinae.desktop $out/share/applications/
      chmod +x $out/bin/vicinae
    '';

    dontWrapQtApps = true;

    preFixup = ''
      wrapQtApp "$out/bin/vicinae" --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}
    '';

    meta = {
      description = "A focused launcher for your desktop — native, fast, extensible";
      homepage = "https://github.com/vicinaehq/vicinae";
      license = pkgs.lib.licenses.gpl3;
      maintainers = [ ];
      platforms = pkgs.lib.platforms.linux;
    };
  };
in
{
  options.vicinae = {
    enable = mkEnableOption "vicinae launcher daemon" // {
      default = true;
    };

    vicinae = mkOption {
      type = types.package;
      default = vicinae;
      defaultText = literalExpression "vicinae";
      description = "The vicinae package to use.";
    };

    autoStart = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to start the vicinae daemon automatically on login.";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} = {
      home.packages = [ cfg.vicinae ];

      # https://docs.vicinae.com/theming#creating-a-custom-theme
      home.file.".config/vicinae/themes/catpuccin.json" = {
        text = builtins.toJSON {
          version = "1.0.0";
          appearance = "dark";
          icon = "";
          name = "Catppuccin";
          description = "Theme generated from NixOS defaults colorScheme";
          palette = {
            background = "#1E1E2E";
            foreground = "#CDD6F4";
            blue = "#89B4FA";
            green = "#A6E3A1";
            magenta = "#F5C2E7";
            orange = "#FAB387";
            purple = "#CBA6F7";
            red = "#F38BA8";
            yellow = "#F9E2AF";
            cyan = "#94E2D5";
          };
        };
      };
      systemd.user.services.vicinae = {
        Unit = {
          Description = "Vicinae launcher daemon";
          After = [ "graphical-session-pre.target" ];
          PartOf = [ "graphical-session.target" ];
        };

        Service = {
          Type = "simple";
          ExecStart = "${cfg.vicinae}/bin/vicinae server";
          Restart = "on-failure";
          RestartSec = 3;
        };

        Install = mkIf cfg.autoStart {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
  };
}
