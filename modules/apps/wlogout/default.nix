{
  lib,
  config,
  pkgs,
  username,
  fullname,
  ...
}:
let
  cfg = config.wlogout;
in
{
  options = {
    wlogout = {
      enable = lib.mkEnableOption "Enable WLogout in home-manager";
    };
  };
  config = lib.mkIf cfg.enable {
    home-manager.users.${username} =
      { config, pkgs, ... }:
      {
        programs.wlogout = {
          enable = true;
          layout = [
            {
              label = "logout";
              action = "loginctl kill-user $(whoami)";
              text = "Logout";
              # keybind = "l";
            }
            {
              label = "lock";
              action = "hyprlock";
              text = "Lock";
              # keybind = "x";
            }
            {
              label = "sleep";
              action = "systemctl suspend";
              text = "Sleep";
              # keybind = "s";
            }
            {
              label = "reboot";
              action = "systemctl reboot";
              text = "Reboot";
              # keybind = "r";
            }
            {
              label = "shutdown";
              action = "shutdown now";
              text = "Shutdown";
              # keybind = "p";
            }
          ];
          style = ''
            * {
              all: unset;
              background-image: none;
              transition: 400ms cubic-bezier(0.05, 0.7, 0.1, 1);
            }

            window {
              background: rgba(0, 0, 0, 0.5);
            }

            button {
              font-family: "Material Symbols Outlined";
              font-size: 10rem;
              background-color: rgba(11, 11, 11, 0.4);
              color: #ffffff;
              margin: 2rem;
              border-radius: 2rem;
              padding: 3rem;
            }

            button:focus,
            button:active,
            button:hover {
              background-color: rgba(51, 51, 51, 0.5);
              border-radius: 4rem;
            }
          '';
        };
      };
  };
}
