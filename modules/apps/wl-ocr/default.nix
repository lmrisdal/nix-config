{
  lib,
  pkgs,
  config,
  username,
  ...
}:
let
  cfg = config.wl-ocr;
in
{
  options = {
    wl-ocr = {
      enable = lib.mkEnableOption "Enable wl-ocr in NixOS";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (pkgs.writeShellScriptBin "wl-ocr" ''
        set -euo pipefail
        # Capture OCR text into a variable (do not copy yet)
        ocr_text="$(${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" -t ppm - \
          | ${pkgs.tesseract}/bin/tesseract -l "eng+nor" - - 2>/dev/null)"
        # Exit early if empty
        if [ -z "$ocr_text" ]; then
          exit 0
        fi
        # Remove a single trailing newline if present
        case "$ocr_text" in
          *$'\n') ocr_text="''${ocr_text%$'\n'}" ;;
        esac
        printf %s "$ocr_text" | ${pkgs.wl-clipboard}/bin/wl-copy
      '')
    ];
    home-manager.users.${username} = { };
  };
}
