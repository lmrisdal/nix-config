{
  lib,
  config,
  username,
  pkgs,
  ...
}:
let
  cfg = config.vicinae;
in
{
  options = {
    vicinae = {
      enable = lib.mkEnableOption "Enable Vicinae (Raycast-like launcher) in home-manager";
    };
  };
  config = lib.mkIf cfg.enable {
    # raycast like hyper key
    services.interception-tools = {
      enable = true;
      plugins = [ pkgs.interception-tools-plugins.dual-function-keys ];
      udevmonConfig = ''
        - JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.dual-function-keys}/bin/dual-function-keys -c /home/${username}/.config/interception/dual-function-keys.yaml | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
          DEVICE:
            EVENTS:
              EV_KEY: [KEY_CAPSLOCK]
      '';
    };
    home-manager.users.${username} = {
      services.vicinae = {
        enable = true;
        autoStart = true;
      };
      home.file = {
        ".config/interception/dual-function-keys.yaml".text = ''
          TIMING:
            TAP_MILLISEC: 200

          MAPPINGS:
            - KEY: KEY_CAPSLOCK
              TAP: KEY_CAPSLOCK
              HOLD:
                - KEY_LEFTCTRL
                - KEY_LEFTALT
                - KEY_LEFTMETA
                - KEY_LEFTSHIFT
        '';
      };
    };
  };
}
