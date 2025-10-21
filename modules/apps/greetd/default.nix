{
  lib,
  config,
  pkgs,
  username,
  defaultSession,
  ...
}:
let
  cfg = config.greetd;
  tuigreet = "${pkgs.tuigreet}/bin/tuigreet";
  session = "uwsm start -F /run/current-system/sw/bin/Hyprland";
in
{
  options = {
    greetd = {
      enable = lib.mkEnableOption "Enable Greetd in NixOS";
    };
  };
  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        # initial_session = {
        #   command = session;
        #   user = username;
        # };
        default_session = {
          user = "root";
          command = "${pkgs.jovian-greeter}/bin/jovian-greeter ${username}";
          # command = "${tuigreet} --greeting 'Welcome to NixOS!' --asterisks --sessions ${config.services.displayManager.sessionData.desktops}/share/xsessions:${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --remember --remember-user-session --time ";
          # user = "greeter";
        };
      };
      greeterManagesPlymouth = true;
    };
    security.pam.services.greetd.enableGnomeKeyring = true;
    services.getty.autologinUser = username;
    systemd.services.plymouth-quit.enable = false;
    users.users.greeter = {
      isNormalUser = false;
      description = "greetd greeter user";
      extraGroups = [
        "video"
        "audio"
      ];
      linger = true;
    };
    security.pam.services = {
      greetd.text = ''
        auth      requisite     pam_nologin.so
        auth      sufficient    pam_succeed_if.so user = ${username} quiet_success
        auth      required      pam_unix.so

        account   sufficient    pam_unix.so

        password  required      pam_deny.so

        session   optional      pam_keyinit.so revoke
        session   include       login
      '';
    };
    security.wrappers.jovian-consume-session = {
      source = "${pkgs.jovian-greeter.helper}/bin/consume-session";
      owner = username;
      group = "users";
      setuid = true;
    };
    home-manager.users.${username} = { config, pkgs, ... }: { };
  };
}
