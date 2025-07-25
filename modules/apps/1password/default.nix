{
  lib,
  config,
  username,
  ...
}:
let
  cfg = config.onepassword;
in
{
  options = {
    onepassword = {
      enable = lib.mkEnableOption "Enable 1Password in NixOS";
    };
  };
  config = lib.mkIf cfg.enable {
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "${username}" ];
    };
    environment.etc = {
      "1password/custom_allowed_browsers" = {
        text = ''
          zen
          librewolf
        '';
        mode = "0755";
      };
    };
    home-manager.users.${username} = {
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
    };
  };
}
