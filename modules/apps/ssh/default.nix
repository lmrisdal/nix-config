{
  lib,
  config,
  username,
  ...
}:
let
  cfg = config.ssh;
in
{
  options = {
    ssh = {
      enable = lib.mkEnableOption "Enable ssh in NixOS";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enableAskPassword = true;
      startAgent = !(config.services.gnome.gnome-keyring.enable or false);
    };
    services.openssh = {
      enable = true;
      listenAddresses = [
        {
          addr = "0.0.0.0";
          port = 22;
        }
      ];
      ports = [ 22 ];
      settings = {
        AllowUsers = [ "${username}" ];
        # Allow forwarding ports to everywhere
        # GatewayPorts = "clientspecified";
        # KbdInteractiveAuthentication = false;
        # KexAlgorithms = [
        #   "sntrup761x25519-sha512@openssh.com"
        #   "curve25519-sha256"
        #   "curve25519-sha256@libssh.org"
        # ];
        #PasswordAuthentication = false;
        PasswordAuthentication = true;
        PermitRootLogin = "no";
        # Automatically remove stale sockets
        # StreamLocalBindUnlink = "yes";
        UseDns = true;
        X11Forwarding = true;
      };
    };
    home-manager.users.${username} = { config, pkgs, ... }: { };
  };
}
