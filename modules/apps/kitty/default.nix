{
  lib,
  config,
  username,
  pkgs,
  ...
}:
let
  cfg = config.kitty;
in
{
  options = {
    kitty = {
      enable = lib.mkEnableOption "Enable kitty in NixOS & home-manager";
    };
  };
  config = lib.mkIf cfg.enable {
    home-manager.users.${username} =
      { pkgs, config, ... }:
      {
        programs.kitty = {
          enable = true;
          settings = {
            # Appearance
            macos_option_as_alt = "left";
            bold_font = "auto";
            italic_font = "auto";
            bold_italic_font = "auto";
            font_size = 10.0;
            background_blur = "1";
            background_opacity = 0.5;
            window_padding_width = "4";
            #background = "#222436";
            foreground = "#c8d3f5";
            selection_background = "#2d3f76";
            selection_foreground = "#c8d3f5";
            url_color = "#4fd6be";
            cursor = "#c8d3f5";
            cursor_text_color = "#222436";

            # Tabs
            active_tab_background = "#82aaff";
            active_tab_foreground = "#1e2030";
            inactive_tab_background = "#2f334d";
            inactive_tab_foreground = "#545c7e";

            # Windows
            active_border_color = "#82aaff";
            inactive_border_color = "#2f334d";
            remember_window_size = "yes";

            # normal
            color0 = "#1b1d2b";
            color1 = "#ff757f";
            color2 = "#c3e88d";
            color3 = "#ffc777";
            color4 = "#82aaff";
            color5 = "#c099ff";
            color6 = "#86e1fc";
            color7 = "#828bb8";

            # bright
            color8 = "#444a73";
            color9 = "#ff8d94";
            color10 = "#c7fb6d";
            color11 = "#ffd8ab";
            color12 = "#9ab8ff";
            color13 = "#caabff";
            color14 = "#b2ebff";
            color15 = "#c8d3f5";

            # extended colors
            color16 = "#ff966c";
            color17 = "#c53b53";

            # behavior
            open_url_with = "default";
          };
          extraConfig = ''
            map ctrl+t new_tab
            map ctrl+w close_tab
            map ctrl+v paste_from_clipboard
            map ctrl+shift+c copy_to_clipboard
            map ctrl+shift+v paste_from_clipboard
          '';
          shellIntegration.enableZshIntegration = true;
          shellIntegration.enableFishIntegration = true;
          shellIntegration.enableBashIntegration = true;
        };
        programs.zsh = {
          shellAliases = {
            ssh = "kitty +kitten ssh";
          };
        };
      };
  };
}
