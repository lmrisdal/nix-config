{
  lib,
  config,
  pkgs,
  username,
  ...
}:
let
  cfg = config.fonts;
  fontSources = {
    sf-pro = {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg";
      hash = "sha256-090HwtgILtK/KGoOzcwz1iAtoiShKAVjiNhUDQtO+gQ=";
    };
    sf-compact = {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Compact.dmg";
      hash = "sha256-z70mts7oFaMTt4q7p6M7PzSw4auOEaiaJPItYqUpN0A=";
    };
    sf-mono = {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg";
      hash = "sha256-bUoLeOOqzQb5E/ZCzq0cfbSvNO1IhW1xcaLgtV2aeUU=";
    };
    sf-arabic = {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Arabic.dmg";
      hash = "sha256-J2DGLVArdwEsSVF8LqOS7C1MZH/gYJhckn30jRBRl7k=";
    };
    ny = {
      url = "https://devimages-cdn.apple.com/design/resources/download/NY.dmg";
      hash = "sha256-HC7ttFJswPMm+Lfql49aQzdWR2osjFYHJTdgjtuI+PQ=";
    };
  };

  makeAppleFont =
    name: pkgName: source:
    pkgs.stdenv.mkDerivation {
      inherit name;

      src = pkgs.fetchurl {
        inherit (source) url hash;
      };

      version = "0.3.0";

      unpackPhase = ''
        undmg $src
        7z x '${pkgName}'
        7z x 'Payload~'
      '';

      buildInputs = [
        pkgs.undmg
        pkgs.p7zip
      ];
      setSourceRoot = "sourceRoot=`pwd`";
      installPhase = ''
        mkdir -p $out/share/fonts/opentype
        mkdir -p $out/share/fonts/truetype
        find -name \*.otf -exec mv {} $out/share/fonts/opentype/ \;
        find -name \*.ttf -exec mv {} $out/share/fonts/truetype/ \;
      '';
    };

  appleColorEmoji = pkgs.stdenv.mkDerivation {
    name = "apple-color-emoji";

    src = pkgs.fetchurl {
      url = "https://github.com/samuelngs/apple-emoji-linux/releases/download/v17.4/AppleColorEmoji.ttf";
      hash = "sha256-SG3JQLybhY/fMX+XqmB/BKhQSBB0N1VRqa+H6laVUPE=";
    };
    unpackPhase = ":";
    installPhase = ''
      mkdir -p $out/share/fonts/truetype
      cp $src $out/share/fonts/truetype/AppleColorEmoji.ttf
    '';
  };
in
{
  options = {
    fonts = {
      enable = lib.mkEnableOption "Enable fonts in NixOS or home-manager";
    };
  };

  config = lib.mkIf cfg.enable {
    fonts = {
      fontDir = {
        enable = true;
      };
      packages = with pkgs; [
        inter
        liberation_ttf
        maple-mono.Normal-NF
        material-design-icons
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
        source-han-sans
        source-han-sans-japanese
        source-han-serif-japanese
        wqy_zenhei
        jetbrains-mono
        noto-fonts-emoji
        (makeAppleFont "sf-pro" "SF Pro Fonts.pkg" fontSources.sf-pro)
        (makeAppleFont "sf-compact" "SF Compact Fonts.pkg" fontSources.sf-compact)
        (makeAppleFont "sf-mono" "SF Mono Fonts.pkg" fontSources.sf-mono)
        (makeAppleFont "sf-arabic" "SF Arabic Fonts.pkg" fontSources.sf-arabic)
        (makeAppleFont "ny" "NY Fonts.pkg" fontSources.ny)
        appleColorEmoji
      ];
      fontconfig = {
        allowBitmaps = false;
        defaultFonts = {
          serif = [ "New York" ];
          sansSerif = [ "SF Pro" ];
          monospace = [ "JetBrainsMono Nerd Font Mono" ];
          emoji = [ "Apple Color Emoji" ];
        };
        useEmbeddedBitmaps = true;
        # subpixel.rgba = "rgb";
      };
    };
    environment = {
      sessionVariables = {
        # https://www.reddit.com/r/linux_gaming/comments/16lwgnj/comment/k1536zb/?utm_source=reddit&utm_medium=web2x&context=3
        FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";
        # https://reddit.com/r/kde/comments/1bjgajv/fractional_scaling_still_seems_to_look_worse_than/kvshkoz/?context=3
        QT_SCALE_FACTOR_ROUNDING_POLICY = "RoundPreferFloor";
      };
    };
    home-manager.users.${username} = { };
  };
}
