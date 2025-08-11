{
  lib,
  config,
  pkgs,
  username,
  fullname,
  ...
}:
let
  cfg = config.keyd;
in
{
  options = {
    keyd = {
      enable = lib.mkEnableOption "Enable keyd in NixOS & home-manager";
    };
  };
  config = lib.mkIf cfg.enable {
    services.keyd = {
      enable = true;
      keyboards = {
        default = {
          ids = [ "*" ]; # what goes into the [id] section, here we select all keyboard
          # extraConfig = builtins.readFile /home/deftdawg/source/meta-mac/keyd/kde-mac-keyboard.conf; # use includes when debugging, easier to edit in vscode
          extraConfig = ''
            # # Make Apple keyboards work the same way on KDE as they do on MacOS
            # [main]
            # # Bind both "Cmd" keys to trigger the 'meta_mac' layer
            # leftmeta = layer(meta_mac)
            # rightmeta = layer(meta_mac)

            # # By default meta_mac = Ctrl+<key>, except for mappings below
            # [meta_mac:C]
            # # Use alternate Copy/Cut/Paste bindings from Windows that won't conflict with Ctrl+C used to break terminal apps
            # # Copy (works everywhere (incl. vscode term) except Konsole)
            # c = C-insert
            # # Paste
            # v = S-insert
            # # Cut
            # x = S-delete

            # # FIXME: for Konsole, we must create a shortcut in our default Konsole profile to bind Copy's Alternate to 'Ctrl+Ins'

            # # Switch directly to an open tab (e.g., Firefox, VS Code)
            # 1 = A-1
            # 2 = A-2
            # 3 = A-3
            # 4 = A-4
            # 5 = A-5
            # 6 = A-6
            # 7 = A-7
            # 8 = A-8
            # 9 = A-9

            # # Move cursor to the beginning of the line
            # left = home
            # # Move cursor to the end of the line
            # right = end

            # # As soon as 'tab' is pressed (but not yet released), switch to the 'app_switch_state' overlay
            # tab = swapm(app_switch_state, A-tab)

            # [app_switch_state:A]
            # # Being in this state holds 'Alt' down allowing us to switch back and forth with tab or arrow presses
            [main]

            # Use the 'leftmeta' key as the new "Cmd" key, activating the 'meta_mac' layer
            leftmeta = layer(meta_mac)
            # leftmeta = overload(meta_mac, leftmeta)
            rightmeta = overload(meta_mac, leftmeta)

            # Optional: Ensure 'leftalt' retains its default behavior (usually not necessary)
            # leftalt = leftalt

            # The 'meta_mac' modifier layer; inherits from the 'Ctrl' modifier layer
            [meta_mac:C]

            # Switch directly to an open tab (e.g., Firefox, VS Code)
            1 = A-1
            2 = A-2
            3 = A-3
            4 = A-4
            5 = A-5
            6 = A-6
            7 = A-7
            8 = A-8
            9 = A-9

            # Gnome maximize shortcut - <super>+up
            up = M-up
            # Gnome un-maximize shortcut - <super>+down
            down = M-down

            # Copy
            c = C-insert
            # Paste
            v = S-insert
            # Cut
            x = S-delete

            # Move cursor to the beginning of the line
            left = home
            # Move cursor to the end of the line
            right = end

            # As soon as 'tab' is pressed (but not yet released), switch to the 'app_switch_state' overlay
            # Send a 'M-tab' key tap before entering 'app_switch_state'
            tab = swapm(app_switch_state, M-tab)

            # Meta-Backtick: Switch to the next window in the application group
            # Default binding for 'cycle-group' in GNOME
            ` = A-f6

            # 'app_switch_state' modifier layer; inherits from the 'Meta' modifier layer
            [app_switch_state:M]

            # Meta-Tab: Switch to the next application
            tab = M-tab
            right = M-tab

            # Meta-Backtick: Switch to the previous application
            ` = M-S-tab
            left = M-S-tab
          '';
        };
      };
    };
  };
}
