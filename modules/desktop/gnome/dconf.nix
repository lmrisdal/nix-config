# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "org/blueman/general" = {
      window-properties = [
        1242
        783
        0
        0
      ];
    };

    "org/blueman/plugins/recentconns" = {
      recent-connections = [
        {
          adapter = "74:D8:3E:D2:12:38";
          address = "0C:35:26:50:03:2A";
          alias = "Xbox Wireless Controller";
          icon = "input-gaming";
          name = "Audio and input profiles";
          uuid = "00000000-0000-0000-0000-000000000000";
          time = "1737232518.040005";
        }
      ];
    };

    "org/gnome/Console" = {
      last-window-maximised = false;
      last-window-size = mkTuple [
        1594
        924
      ];
    };

    "org/gnome/Extensions" = {
      window-height = 825;
      window-width = 1042;
    };

    "org/gnome/Geary" = {
      images-trusted-domains = [ "*" ];
      migrated-config = true;
      window-height = 860;
      window-width = 1707;
    };

    "org/gnome/Music" = {
      window-maximized = false;
      window-size = [
        1524
        902
      ];
    };

    "org/gnome/Totem" = {
      active-plugins = [
        "vimeo"
        "variable-rate"
        "skipto"
        "screenshot"
        "screensaver"
        "save-file"
        "rotation"
        "recent"
        "movie-properties"
        "open-directory"
        "mpris"
        "autoload-subtitles"
        "apple-trailers"
      ];
      subtitle-encoding = "UTF-8";
    };

    "org/gnome/calendar" = {
      active-view = "month";
      window-maximized = false;
      window-size = mkTuple [
        1361
        815
      ];
    };

    "org/gnome/control-center" = {
      last-panel = "bluetooth";
      window-state = mkTuple [
        1324
        894
        false
      ];
    };

    "org/gnome/desktop/app-folders" = {
      folder-children = [
        "Utilities"
        "YaST"
        "Pardus"
      ];
    };

    "org/gnome/desktop/app-folders/folders/Pardus" = {
      categories = [ "X-Pardus-Apps" ];
      name = "X-Pardus-Apps.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/Utilities" = {
      apps = [
        "org.freedesktop.GnomeAbrt.desktop"
        "nm-connection-editor.desktop"
        "org.gnome.baobab.desktop"
        "org.gnome.Connections.desktop"
        "org.gnome.DejaDup.desktop"
        "org.gnome.DiskUtility.desktop"
        "org.gnome.Evince.desktop"
        "org.gnome.FileRoller.desktop"
        "org.gnome.font-viewer.desktop"
        "org.gnome.Loupe.desktop"
        "org.gnome.seahorse.Application.desktop"
        "org.gnome.tweaks.desktop"
        "org.gnome.Usage.desktop"
      ];
      categories = [ "X-GNOME-Utilities" ];
      name = "X-GNOME-Utilities.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/YaST" = {
      categories = [ "X-SuSE-YaST" ];
      name = "suse-yast.directory";
      translate = true;
    };

    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-l.svg";
      picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-d.svg";
      primary-color = "#241f31";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/input-sources" = {
      sources = [
        (mkTuple [
          "xkb"
          "no"
        ])
      ];
      xkb-options = [ "terminate:ctrl_alt_bksp" ];
    };

    "org/gnome/desktop/interface" = {
      accent-color = "red";
      color-scheme = "prefer-dark";
      toolkit-accessibility = false;
    };

    "org/gnome/desktop/notifications" = {
      application-children = [
        "org-gnome-console"
        "firefox"
        "spotify"
        "discord"
        "steam"
        "org-gnome-nautilus"
        "org-gnome-evolution-alarm-notify"
      ];
    };

    "org/gnome/desktop/notifications/application/discord" = {
      application-id = "discord.desktop";
    };

    "org/gnome/desktop/notifications/application/firefox" = {
      application-id = "firefox.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-console" = {
      application-id = "org.gnome.Console.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-evolution-alarm-notify" = {
      application-id = "org.gnome.Evolution-alarm-notify.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-nautilus" = {
      application-id = "org.gnome.Nautilus.desktop";
    };

    "org/gnome/desktop/notifications/application/spotify" = {
      application-id = "spotify.desktop";
    };

    "org/gnome/desktop/notifications/application/steam" = {
      application-id = "steam.desktop";
    };

    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
      speed = 0.35338345864661647;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-l.svg";
      primary-color = "#241f31";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/sound" = {
      event-sounds = true;
      theme-name = "__custom";
    };

    "org/gnome/desktop/wm/preferences" = {
      mouse-button-modifier = "<Alt>";
      resize-with-right-button = true;
    };

    "org/gnome/epiphany" = {
      ask-for-default = false;
    };

    "org/gnome/epiphany/state" = {
      is-maximized = false;
      window-size = mkTuple [
        1024
        768
      ];
    };

    "org/gnome/evolution-data-server" = {
      migrated = true;
    };

    "org/gnome/evolution-data-server/calendar" = {
      reminders-past = [
        "b27805347036bdcb546f3460791c0dec8a4fc372nde7c23c4edf29b9e03705cc9d04ed2b37adec944t20250119T140000Zn1737294300n1737295200n1737302400nBEGIN:VEVENTrnDTSTART:20250119T140000ZrnDTEND:20250119T160000ZrnDTSTAMP:20250118T144513ZrnUID:66716216d7f02ab1311e3c05@google.comrnCREATED:20240618T133830ZrnDESCRIPTION:Live coverage on: Check your local guides | #MUNBHA\\n\\nFollow rn the match live on the Official Manchester United app: https:rn //ql.e-c.al/manutdapp\\n\\nPlay the biggest Fantasy Football game in the rn world. Register here: https://ql.e-c.al/PLfantasy\\n\\nTV Schedule\\nhttps:rn //premlge.co/f/v6L2P/LBxr\\n\\nMatch Centre\\nhttps:rn //premlge.co/f/v6L3j/LBxr\\n\\nManchester United Shop\\nhttps:rn //premlge.co/f/v6L3L/LBxr\\n\\nManchester United X\\nhttps:rn //premlge.co/f/v6L4r/LBxr\\n\\nManage my ECAL\\nhttps:rn //premlge.co/f/v6L5q/LBxr\\n\\nrnLAST-MODIFIED:20250118T144513ZrnLOCATION:Old Trafford\\, ManchesterrnSEQUENCE:1rnSTATUS:CONFIRMEDrnSUMMARY:\9917\65039 Manchester United v Brighton & Hove AlbionrnTRANSP:TRANSPARENTrnX-EVOLUTION-CALDAV-ETAG:63872894713rnBEGIN:VALARMrnACTION:DISPLAYrnDESCRIPTION:This is an event reminderrnTRIGGER:-PT15MrnX-EVOLUTION-ALARM-UID:de7c23c4edf29b9e03705cc9d04ed2b37adec944rnEND:VALARMrnBEGIN:VALARMrnACTION:DISPLAYrnDESCRIPTION:This is an event reminderrnTRIGGER:-P1DrnX-EVOLUTION-ALARM-UID:ba0d1646b881f383cea37d3505d6b6a8d99af2f8rnEND:VALARMrnEND:VEVENTrn"
      ];
    };

    "org/gnome/file-roller/listing" = {
      list-mode = "as-folder";
      name-column-width = 65;
      show-path = false;
      sort-method = "name";
      sort-type = "ascending";
    };

    "org/gnome/file-roller/ui" = {
      sidebar-width = 200;
      window-height = 480;
      window-width = 600;
    };

    "org/gnome/gnome-system-monitor" = {
      cpu-colors = [
        (mkTuple [
          (mkUint32 0)
          "#e01b24"
        ])
        (mkTuple [
          1
          "#ff7800"
        ])
        (mkTuple [
          2
          "#f6d32d"
        ])
        (mkTuple [
          3
          "#33d17a"
        ])
        (mkTuple [
          4
          "#26a269"
        ])
        (mkTuple [
          5
          "#62a0ea"
        ])
        (mkTuple [
          6
          "#1c71d8"
        ])
        (mkTuple [
          7
          "#613583"
        ])
        (mkTuple [
          8
          "#9141ac"
        ])
        (mkTuple [
          9
          "#c061cb"
        ])
        (mkTuple [
          10
          "#ffbe6f"
        ])
        (mkTuple [
          11
          "#f9f06b"
        ])
        (mkTuple [
          12
          "#8ff0a4"
        ])
        (mkTuple [
          13
          "#2ec27e"
        ])
        (mkTuple [
          14
          "#1a5fb4"
        ])
        (mkTuple [
          15
          "#c061cb"
        ])
        (mkTuple [
          16
          "#de7a7999f332"
        ])
        (mkTuple [
          17
          "#7999f332baff"
        ])
        (mkTuple [
          18
          "#f33297837999"
        ])
        (mkTuple [
          19
          "#79997f29f332"
        ])
        (mkTuple [
          20
          "#a2a5f3327999"
        ])
        (mkTuple [
          21
          "#f3327999c620"
        ])
        (mkTuple [
          22
          "#7999e99bf332"
        ])
        (mkTuple [
          23
          "#f332d94d7999"
        ])
      ];
      show-dependencies = false;
      show-whose-processes = "user";
    };

    "org/gnome/maps" = {
      last-viewed-location = [
        59.920200052690404
        10.778508533509978
      ];
      map-type = "MapsVectorSource";
      transportation-type = "transit";
      window-maximized = false;
      window-size = [
        2035
        1207
      ];
      zoom-level = 13;
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
      migrated-gtk-settings = true;
      search-filter-time-type = "last_modified";
    };

    "org/gnome/nautilus/window-state" = {
      initial-size = mkTuple [
        1231
        782
      ];
      initial-size-file-chooser = mkTuple [
        890
        550
      ];
    };

    "org/gnome/portal/filechooser/brave-browser" = {
      last-folder-path = "/home/lars/Downloads";
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-schedule-automatic = false;
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Shift><Control>space";
      command = "1password --quick-access";
      name = "1Password quickaccess";
    };

    "org/gnome/shell" = {
      disabled-extensions = [
        "openbar@neuromorph"
        "dash-to-panel@jderose9.github.com"
      ];
      enabled-extensions = [
        "apps-menu@gnome-shell-extensions.gcampax.github.com"
        "dash-to-dock@micxgx.gmail.com"
      ];
      favorite-apps = [
        "brave-browser.desktop"
        "org.gnome.Nautilus.desktop"
        "org.gnome.Calendar.desktop"
        "code.desktop"
        "org.gnome.Console.desktop"
      ];
      welcome-dialog-last-shown-version = "47.2";
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      apply-custom-theme = false;
      background-opacity = 0.74;
      custom-theme-shrink = false;
      dash-max-icon-size = 48;
      dock-fixed = true;
      dock-position = "RIGHT";
      height-fraction = 0.9;
      max-alpha = 0.8;
      multi-monitor = false;
      preferred-monitor = -2;
      preferred-monitor-by-connector = "DP-1";
      transparency-mode = "DYNAMIC";
    };

    "org/gnome/shell/extensions/dash-to-panel" = {
      animate-appicon-hover-animation-extent = {
        RIPPLE = 4;
        PLANK = 4;
        SIMPLE = 1;
      };
      appicon-margin = 8;
      appicon-padding = 4;
      available-monitors = [
        0
        1
      ];
      dot-position = "BOTTOM";
      hotkeys-overlay-combo = "TEMPORARILY";
      leftbox-padding = -1;
      multi-monitors = false;
      panel-anchors = ''
        {"0":"MIDDLE","1":"MIDDLE"}
      '';
      panel-element-positions = ''
        {"0":[{"element":"showAppsButton","visible":true,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"centered"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}],"1":[{"element":"showAppsButton","visible":true,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"centered"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}]}
      '';
      panel-lengths = ''
        {"0":100,"1":100}
      '';
      panel-sizes = ''
        {"0":48,"1":48}
      '';
      primary-monitor = 0;
      status-icon-padding = -1;
      tray-padding = -1;
      window-preview-title-position = "TOP";
    };

    "org/gnome/shell/extensions/openbar" = {
      autofg-bar = true;
      autohg-bar = true;
      autohg-menu = true;
      autotheme-dark = "Pastel";
      autotheme-font = true;
      balpha = 0.23;
      bcolor = [
        "0.000"
        "0.000"
        "0.000"
      ];
      bg-change = true;
      bgalpha = 0.95;
      bgcolor = [
        "0.459"
        "0.141"
        "0.294"
      ];
      bgcolor-wmax = [
        "0.118"
        "0.118"
        "0.118"
      ];
      bgcolor2 = [
        "0.898"
        "0.796"
        "0.863"
      ];
      bguri = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-d.svg";
      boxalpha = 0.0;
      boxcolor = [
        "0.459"
        "0.141"
        "0.294"
      ];
      bradius = 50.0;
      bwidth = 0.0;
      count1 = 294832;
      count10 = 0;
      count11 = 0;
      count12 = 0;
      count2 = 241987;
      count3 = 212468;
      count4 = 111812;
      count5 = 66696;
      count6 = 27919;
      count7 = 27811;
      count8 = 16416;
      count9 = 59;
      dark-bcolor = [
        "0.000"
        "0.000"
        "0.000"
      ];
      dark-bgcolor = [
        "0.459"
        "0.141"
        "0.294"
      ];
      dark-bgcolor-wmax = [
        "0.118"
        "0.118"
        "0.118"
      ];
      dark-bgcolor2 = [
        "0.898"
        "0.796"
        "0.863"
      ];
      dark-bguri = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-d.svg";
      dark-boxcolor = [
        "0.459"
        "0.141"
        "0.294"
      ];
      dark-hcolor = [
        "0.627"
        "0.137"
        "0.251"
      ];
      dark-hscd-color = [
        "0.847"
        "0.322"
        "0.251"
      ];
      dark-iscolor = [
        "0.459"
        "0.141"
        "0.294"
      ];
      dark-mbcolor = [
        "0.627"
        "0.137"
        "0.251"
      ];
      dark-mbgcolor = [
        "0.808"
        "0.682"
        "0.733"
      ];
      dark-mhcolor = [
        "0.627"
        "0.137"
        "0.251"
      ];
      dark-mscolor = [
        "0.847"
        "0.322"
        "0.251"
      ];
      dark-mshcolor = [
        "0.000"
        "0.000"
        "0.000"
      ];
      dark-palette1 = [
        "36"
        "28"
        "52"
      ];
      dark-palette10 = [
        "160"
        "35"
        "64"
      ];
      dark-palette11 = [
        "76"
        "72"
        "68"
      ];
      dark-palette12 = [
        "68"
        "28"
        "68"
      ];
      dark-palette2 = [
        "63"
        "36"
        "66"
      ];
      dark-palette3 = [
        "189"
        "53"
        "34"
      ];
      dark-palette4 = [
        "117"
        "36"
        "75"
      ];
      dark-palette5 = [
        "97"
        "36"
        "76"
      ];
      dark-palette6 = [
        "147"
        "28"
        "75"
      ];
      dark-palette7 = [
        "224"
        "94"
        "4"
      ];
      dark-palette8 = [
        "41"
        "36"
        "52"
      ];
      dark-palette9 = [
        "44"
        "36"
        "60"
      ];
      dark-shcolor = [
        "0.000"
        "0.000"
        "0.000"
      ];
      dark-smbgcolor = [
        "0.898"
        "0.796"
        "0.863"
      ];
      dark-vw-color = [
        "0.847"
        "0.322"
        "0.251"
      ];
      dark-winbcolor = [
        "0.847"
        "0.322"
        "0.251"
      ];
      dashdock-style = "Default";
      default-font = "Sans 12";
      fgalpha = 1.0;
      hcolor = [
        "0.627"
        "0.137"
        "0.251"
      ];
      hscd-color = [
        "0.847"
        "0.322"
        "0.251"
      ];
      import-export = false;
      isalpha = 0.95;
      iscolor = [
        "0.459"
        "0.141"
        "0.294"
      ];
      light-bguri = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-l.svg";
      light-palette1 = [
        "44"
        "37"
        "60"
      ];
      light-palette10 = [
        "44"
        "40"
        "64"
      ];
      light-palette11 = [
        "44"
        "40"
        "64"
      ];
      light-palette12 = [
        "44"
        "40"
        "64"
      ];
      light-palette2 = [
        "71"
        "43"
        "80"
      ];
      light-palette3 = [
        "187"
        "48"
        "73"
      ];
      light-palette4 = [
        "144"
        "44"
        "97"
      ];
      light-palette5 = [
        "100"
        "52"
        "97"
      ];
      light-palette6 = [
        "212"
        "75"
        "36"
      ];
      light-palette7 = [
        "226"
        "104"
        "4"
      ];
      light-palette8 = [
        "211"
        "83"
        "4"
      ];
      light-palette9 = [
        "52"
        "41"
        "60"
      ];
      mbcolor = [
        "0.627"
        "0.137"
        "0.251"
      ];
      mbgcolor = [
        "0.808"
        "0.682"
        "0.733"
      ];
      mfgalpha = 1.0;
      mhcolor = [
        "0.627"
        "0.137"
        "0.251"
      ];
      monitor-height = 1440;
      monitor-width = 3440;
      mscolor = [
        "0.847"
        "0.322"
        "0.251"
      ];
      mshcolor = [
        "0.000"
        "0.000"
        "0.000"
      ];
      neon = true;
      palette1 = [
        "36"
        "28"
        "52"
      ];
      palette10 = [
        "160"
        "35"
        "64"
      ];
      palette11 = [
        "76"
        "72"
        "68"
      ];
      palette12 = [
        "68"
        "28"
        "68"
      ];
      palette2 = [
        "63"
        "36"
        "66"
      ];
      palette3 = [
        "189"
        "53"
        "34"
      ];
      palette4 = [
        "117"
        "36"
        "75"
      ];
      palette5 = [
        "97"
        "36"
        "76"
      ];
      palette6 = [
        "147"
        "28"
        "75"
      ];
      palette7 = [
        "224"
        "94"
        "4"
      ];
      palette8 = [
        "41"
        "36"
        "52"
      ];
      palette9 = [
        "44"
        "36"
        "60"
      ];
      pause-reload = false;
      reloadstyle = false;
      shcolor = [
        "0.000"
        "0.000"
        "0.000"
      ];
      smbgcolor = [
        "0.898"
        "0.796"
        "0.863"
      ];
      trigger-autotheme = true;
      trigger-reload = false;
      vw-color = [
        "0.847"
        "0.322"
        "0.251"
      ];
      width-bottom = true;
      width-left = true;
      width-right = false;
      width-top = true;
      winbcolor = [
        "0.847"
        "0.322"
        "0.251"
      ];
    };

    "org/gnome/shell/world-clocks" = {
      locations = [ ];
    };

    "org/gnome/software" = {
      check-timestamp = mkInt64 1737281088;
      first-run = false;
    };

    "org/gtk/gtk4/settings/color-chooser" = {
      custom-colors = [
        (mkTuple [
          0.1411764770746231
          0.10980392247438431
          0.20392157137393951
          1.0
        ])
        (mkTuple [
          0.9800000190734863
          0.45500001311302185
          8.60000029206276e-2
          1.0
        ])
      ];
      selected-color = mkTuple [
        true
        1.0
        1.0
        1.0
        1.0
      ];
    };

    "org/gtk/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 157;
      sort-column = "name";
      sort-directories-first = false;
      sort-order = "ascending";
      type-format = "category";
      window-position = mkTuple [
        1245
        1676
      ];
      window-size = mkTuple [
        1231
        902
      ];
    };

  };
}
