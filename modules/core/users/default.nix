{
  lib,
  config,
  username,
  fullname,
  pkgs,
  ...
}:
let
  cfg = config.users;
in
{
  options = {
    users = {
      enable = lib.mkEnableOption "Enable users in NixOS & home-manager";
    };
  };
  config = lib.mkIf cfg.enable {
    users = {
      defaultUserShell = pkgs.zsh;
      groups = {
        adbusers = { };
        plugdev = { };
      };
      mutableUsers = true;
      users = {
        "${username}" = {
          description = "${fullname}";
          isNormalUser = true;
          initialHashedPassword = "$y$j9T$ZzlRbcoRcibLQIEuh5Mfo/$.kkpqP/Z1Rijn1sqp2jjZjIar5ooogxAp7TPY5pzRL2";
          extraGroups = [
            "adbusers"
            "audio"
            "i2c"
            "input"
            "networkmanager"
            "plugdev"
            "realtime"
            "uinput"
            "video"
            "wheel"
            "bluetooth"
          ];
        };
      };
    };
    home-manager.users.${username} = { };
  };
}
