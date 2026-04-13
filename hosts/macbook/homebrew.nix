{
  lib,
  config,
  pkgs,
  username,
  ...
}:
let
  cfg = config.brew;
in
{
  options = {
    brew = {
      enable = lib.mkEnableOption "Enable Homebrew in NixOS";
    };
  };
  config = lib.mkIf cfg.enable {
    homebrew = {
      enable = true;
      onActivation = {
        upgrade = false;
        cleanup = "zap";
      };
      brews = [
        "azure-cli"
        "azure-functions-core-tools@4"
        "p7zip"
        "rust"
        "innoextract"
        "llvm"
        "rustup"
        "gemini-cli"
        "opencode"
        "nano"
        "gh"
        "tree"
        "exiftool"
      ];
      taps = [
        "azure/functions"
        "xykong/tap"
        {
          name = "sbarex/SourceCodeSyntaxHighlight";
          clone_target = "git@github.com:sbarex/SourceCodeSyntaxHighlight.git";
        }
      ];
      casks = [
        "betterdisplay"
        "sbarex/SourceCodeSyntaxHighlight/syntax-highlight"
        "quicklook-video"
        "xykong/tap/flux-markdown"
        "dockdoor"
        "spotify"
        "chatgpt"
        "raycast"
        "discord"
        "rectangle"
        "monitorcontrol"
        "the-unarchiver"
        "keka"
        "linearmouse"
        "visual-studio-code"
        "1password"
        "zen"
        "pearcleaner"
        "redis-insight"
        "parallels"
        "rustdesk"
        "libreoffice"
        "postman"
        "cyberduck"
        "iina"
        "docker-desktop"
        "antigravity"
        "google-chrome"
        "claude-code"
        "dotnet-sdk"
        "lm-studio"
        "codex"
        "codex-app"
        "cursor"
        "cursor-cli"
        "zed"
      ];
      masApps = {
        "1Password for Safari" = 1569813296;
        "Tailscale" = 1475387142;
        "Wireguard" = 1451685025;
        "Adobe Lightroom" = 1451544217;
      };
    };
  };
}
