{
  lib,
  config,
  username,
  ...
}:
let
  cfg = config.spotify;
in
{
  options = {
    spotify = {
      enable = lib.mkEnableOption "Enable Spotify in NixOS & home-manager";
    };
  };
  config = lib.mkIf cfg.enable {
    services.flatpak = {
      overrides = {
        "com.spotify.Client" = {
          Environment = {
            PULSE_SINK = "Music";
          };
        };
      };
      packages = [
        "com.spotify.Client"
      ];
    };
  };
}
