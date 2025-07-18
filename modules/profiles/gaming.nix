{
  inputs,
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  cfg = config.gaming;
  scripts = pkgs.callPackage ../modules/scripts { };
in
{
  options = {
    gaming = {
      enable = lib.mkEnableOption "Enable Gaming module in NixOS";
    };
  };

  config = lib.mkIf cfg.enable {
    # Custom modules
    bottles.enable = true;
    gamemode.enable = false;
    gamescope.enable = true;
    heroic.enable = true;
    lutris.enable = true;
    mangohud.enable = true;
    obs.enable = true;
    steam.enable = true;
    vkbasalt.enable = true;
    # sunshine.enable = true;

    boot = {
      kernelModules = [
        "ntsync"
      ];
      # kernelPackages = lib.mkForce pkgs.linuxPackages_cachyos;
      kernelParams = [
        "tsc=reliable"
        "clocksource=tsc"
        "mitigations=off"
        "preempt=full" # https://reddit.com/r/linux_gaming/comments/1g0g7i0/god_of_war_ragnarok_crackling_audio/lr8j475/?context=3#lr8j475
        "split_lock_detect=off"
      ];
      kernel = {
        sysctl = {
          "vm.max_map_count" = 2147483642;
          "vm.mmap_min_addr" = 0; # SheepShaver
          # https://github.com/CachyOS/CachyOS-Settings/blob/master/usr/lib/sysctl.d/99-cachyos-settings.conf
          "fs.file-max" = 2097152;
          "kernel.split_lock_mitigate" = 0;
          "net.core.netdev_max_backlog" = 4096;
          "net.ipv4.tcp_fin_timeout" = 5;
          "vm.dirty_background_bytes" = 67108864;
          "vm.dirty_bytes" = 268435456;
          "vm.dirty_writeback_centisecs" = 1500;
          "vm.page-cluster" = 0;
          "vm.vfs_cache_pressure" = 50;
        };
      };
    };

    hardware = {
      uinput.enable = true;
      xpadneo.enable = true;
      xone.enable = true; # Xbox controller dongle
    };

    nix.settings = {
      extra-substituters = [
        "https://just-one-more-cache.cachix.org/"
        "https://nix-gaming.cachix.org"
        "https://nix-citizen.cachix.org"
      ];
      extra-trusted-public-keys = [
        "just-one-more-cache.cachix.org-1:4nShcKEgcUEVlJqKFrgDwoGfqLnw5KPG4UDTV02jnr4="
        "nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      ];
    };

    security = {
      pam = {
        loginLimits = [
          {
            domain = "*";
            item = "memlock";
            type = "-";
            value = "unlimited";
          }
          {
            domain = "*";
            item = "nofile";
            type = "-";
            value = "2097152";
          }
        ];
      };
    };

    services = {
      input-remapper = {
        enable = true;
      };
      # scx = {
      #   enable = true;
      #   package = pkgs.scx.rustscheds;
      #   scheduler = "scx_lavd";
      # };
    };

    systemd = {
      extraConfig = ''
        DefaultLimitNOFILE=1048576
      '';
      tmpfiles = {
        rules = [
          # AMD V-Cache
          # https://wiki.cachyos.org/configuration/general_system_tweaks/#amd-3d-v-cache-optimizer
          # "w /sys/bus/platform/drivers/amd_x3d_vcache/AMDI0101:00/amd_x3d_mode - - - - cache"
          # https://wiki.archlinux.org/title/Gaming#Make_the_changes_permanent
          "w /proc/sys/vm/compaction_proactiveness - - - - 0"
          "w /proc/sys/vm/watermark_boost_factor - - - - 1"
          "w /proc/sys/vm/min_free_kbytes - - - - 1048576"
          "w /proc/sys/vm/watermark_scale_factor - - - - 500"
          "w /sys/kernel/mm/lru_gen/enabled - - - - 5"
          "w /proc/sys/vm/zone_reclaim_mode - - - - 0"
          "w /proc/sys/vm/page_lock_unfairness - - - - 1"
          "w /proc/sys/kernel/sched_child_runs_first - - - - 0"
          "w /proc/sys/kernel/sched_autogroup_enabled - - - - 1"
          "w /proc/sys/kernel/sched_cfs_bandwidth_slice_us - - - - 3000"
          "w /sys/kernel/debug/sched/base_slice_ns  - - - - 3000000"
          "w /sys/kernel/debug/sched/migration_cost_ns - - - - 500000"
          "w /sys/kernel/debug/sched/nr_migrate - - - - 8"
        ];
      };
    };

    home-manager.users.${username} =
      {
        inputs,
        config,
        ...
      }:
      {
        home = {
          file =
            let
              primaryscreen = "HDMI-1";
            in
            {
              desktop-entry-dxvk =
                let
                  configFile = pkgs.fetchurl {
                    url = "https://raw.githubusercontent.com/doitsujin/dxvk/master/dxvk.conf";
                    hash = "sha256-at2s/DZEwkzQT47rBOWRfd0jBu1pJuqsqyHslMbjVfk=";
                  };
                in
                {
                  enable = true;
                  text = ''
                    [Desktop Entry]
                    Comment=Create a new DXVK config from template
                    Icon=text-plain
                    Name=DXVK Config...
                    Type=Link
                    URL[$e]=file:${configFile}
                  '';
                  target = "${config.xdg.dataHome}/templates/dxvk.desktop";
                };
              desktop-entry-mangohud =
                let
                  configFile = pkgs.fetchurl {
                    url = "https://raw.githubusercontent.com/flightlessmango/MangoHud/master/data/MangoHud.conf";
                    hash = "sha256-v4HdqQtJBvPR19SNf+FxoV5wJ+0Ou/1UYAkIwskXIWc=";
                  };
                in
                {
                  enable = true;
                  text = ''
                    [Desktop Entry]
                    Comment=Create a new MangoHud config from template
                    Icon=io.github.flightlessmango.mangohud
                    Name=MangoHud Config...
                    Type=Link
                    URL[$e]=file:${configFile}
                  '';
                  target = "${config.xdg.dataHome}/templates/mangohud.desktop";
                };
              desktop-entry-vkBasalt =
                let
                  configFile = pkgs.fetchurl {
                    url = "https://raw.githubusercontent.com/DadSchoorse/vkBasalt/master/config/vkBasalt.conf";
                    hash = "sha256-IN/Kuc17EZfzRoo8af1XoBX2/48/bCdyOxw/Tl463Mg=";
                  };
                in
                {
                  enable = true;
                  text = ''
                    [Desktop Entry]
                    Comment=Create a new vkBasalt config from template
                    Icon=text-plain
                    Name=vkBasalt Config...
                    Type=Link
                    URL[$e]=file:${configFile}
                  '';
                  target = "${config.xdg.dataHome}/templates/vkBasalt.desktop";
                };
              screen-hdr-off = {
                enable = true;
                source =
                  with pkgs;
                  lib.getExe (writeShellApplication {
                    name = "hdr-off";
                    runtimeInputs = [
                      kdePackages.libkscreen
                    ];
                    text = ''
                      kscreen-doctor output.${primaryscreen}.hdr.disable output.${primaryscreen}.wcg.disable
                    '';
                  });
                target = "${config.xdg.dataHome}/scripts/hdr-off.sh";
              };
              screen-hdr-on = {
                enable = true;
                source =
                  with pkgs;
                  lib.getExe (writeShellApplication {
                    name = "hdr-on";
                    runtimeInputs = [
                      kdePackages.libkscreen
                    ];
                    text = ''
                      kscreen-doctor output.${primaryscreen}.hdr.enable output.${primaryscreen}.wcg.enable
                    '';
                  });
                target = "${config.xdg.dataHome}/scripts/hdr-on.sh";
              };
              screen-vrr-off = {
                enable = true;
                source =
                  with pkgs;
                  lib.getExe (writeShellApplication {
                    name = "vrr-off";
                    runtimeInputs = [
                      kdePackages.libkscreen
                    ];
                    text = ''
                      kscreen-doctor output.${primaryscreen}.vrrpolicy.never
                    '';
                  });
                target = "${config.xdg.dataHome}/scripts/vrr-off.sh";
              };
              screen-vrr-on = {
                enable = true;
                source =
                  with pkgs;
                  lib.getExe (writeShellApplication {
                    name = "vrr-on";
                    runtimeInputs = [
                      kdePackages.libkscreen
                    ];
                    text = ''
                      kscreen-doctor output.${primaryscreen}.vrrpolicy.automatic
                    '';
                  });
                target = "${config.xdg.dataHome}/scripts/vrr-on.sh";
              };
              wine-controller-proton = {
                # https://selfmadepenguin.wordpress.com/2024/02/14/how-i-solved-my-gamecontroller-problems/
                # Import with: wine start regedit.exe /home/lars/.local/share/wine-controller.reg
                enable = true;
                text = ''
                  Windows Registry Editor Version 5.00

                  [HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\winebus]
                  "DisableHidraw"=dword:00000001
                  "Enable SDL"=dword:00000001
                '';
                target = "${config.xdg.dataHome}/scripts/wine-controller.reg";
              };
              wine-mouse-acceleration = {
                # https://reddit.com/r/linux_gaming/comments/1hs1685/windows_mouse_acceleration_seems_to_be_enabled_in/
                # Import with: wine start regedit.exe /home/lars/.local/share/wine-mouse-acceleration.reg
                enable = true;
                text = ''
                  Windows Registry Editor Version 5.00

                  [HKEY_CURRENT_USER\Control Panel\Mouse]
                  "MouseSpeed"="0"
                  "MouseThreshold1"="0"
                  "MouseThreshold2"="0"
                '';
                target = "${config.xdg.dataHome}/scripts/wine-mouse-acceleration.reg";
              };
            };
        };

        services = {
          # flatpak = {
          #   overrides = {
          #     global = {
          #       Environment = {
          #         PULSE_SINK = "Game";
          #       };
          #     };
          #     "info.cemu.Cemu" = {
          #       Context = {
          #         filesystems = [
          #           "!home"
          #           # "${config.home.homeDirectory}/Games/Emulator/cemu"
          #         ];
          #       };
          #     };
          #     "io.github.ryubing.Ryujinx" = {
          #       Context = {
          #         filesystems = [
          #           "!home"
          #           # "${config.home.homeDirectory}/Games/Emulator/switch"
          #         ];
          #       };
          #     };
          #     "net.kuribo64.melonDS" = {
          #       Context = {
          #         filesystems = [
          #           "!home"
          #           # "/mnt/crusader/Games/Backups/Myrient/No-Intro"
          #         ];
          #       };
          #     };
          #     "net.pcsx2.PCSX2" = {
          #       Context = {
          #         filesystems = [
          #           "!home"
          #           # "/mnt/crusader/Games/Rom/CHD/Sony Playstation 2"
          #         ];
          #       };
          #     };
          #     "net.rpcs3.RPCS3" = {
          #       Context = {
          #         filesystems = [
          #           "!home"
          #           # "${config.home.homeDirectory}/Games/Emulator/rpcs3"
          #         ];
          #       };
          #     };
          #     "org.duckstation.DuckStation" = {
          #       Context = {
          #         filesystems = [
          #           "!home"
          #           # "${config.home.homeDirectory}/Games/Emulator/Sony PlayStation"
          #         ];
          #       };
          #     };
          #     "org.DolphinEmu.dolphin-emu" = {
          #       Context = {
          #         filesystems = [
          #           "!home"
          #           # "${config.home.homeDirectory}/Games/Emulator/dolphin"
          #         ];
          #       };
          #     };
          #     "org.easyrpg.player" = {
          #       Context = {
          #         filesystems = [
          #           # "${config.home.homeDirectory}/Games/Emulator/rpg-maker"
          #           "!home"
          #           "!host"
          #         ];
          #         shared = "network"; # obs-gamecapture
          #       };
          #       Environment = {
          #         RPG2K_RTP_PATH = "${config.home.homeDirectory}/Games/Emulator/rpg-maker/RTP/2000";
          #         RPG2K3_RTP_PATH = "${config.home.homeDirectory}/Games/Emulator/rpg-maker/RTP/2003";
          #       };
          #     };
          #   };
          #   packages = [
          #     "app.xemu.xemu"
          #     "info.cemu.Cemu"
          #     "io.github.ryubing.Ryujinx"
          #     "net.kuribo64.melonDS"
          #     "net.rpcs3.RPCS3"
          #     "org.DolphinEmu.dolphin-emu"
          #     "org.duckstation.DuckStation"
          #     "org.easyrpg.player"
          #   ];
          # };
          # ludusavi = {
          #   enable = true;
          #   backupNotification = true;
          #   settings = {
          #     backup = {
          #       path = "${config.home.homeDirectory}/Games/games/ludusavi";
          #       format = {
          #         chosen = "zip";
          #         zip.compression = "deflate";
          #       };
          #     };
          #     customGames = [
          #       {
          #         name = "Dolphin-Emu";
          #         files = [
          #           "${config.xdg.dataHome}/dolphin-emu/StateSaves"
          #           "${config.home.homeDirectory}/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/StateSaves"
          #         ];
          #       }
          #       {
          #         name = "Duckstation";
          #         files = [
          #           "${config.xdg.configHome}/duckstation/memcards"
          #           "${config.xdg.configHome}/duckstation/savestates"
          #           "${config.home.homeDirectory}/.var/app/org.duckstation.DuckStation/config/duckstation/memcards"
          #           "${config.home.homeDirectory}/.var/app/org.duckstation.DuckStation/config/duckstation/savestates"
          #         ];
          #       }
          #       {
          #         name = "OpenMW";
          #         files = [
          #           "${config.xdg.dataHome}/openmw/saves"
          #         ];
          #       }
          #       {
          #         name = "PCSX2";
          #         files = [
          #           "${config.xdg.configHome}/PCSX2/memcards"
          #           "${config.xdg.configHome}/PCSX2/sstates"
          #           "${config.home.homeDirectory}/.var/app/net.pcsx2.PCSX2/config/PCSX2/memcards"
          #           "${config.home.homeDirectory}/.var/app/net.pcsx2.PCSX2/config/PCSX2/sstates"
          #         ];
          #       }
          #     ];
          #     restore = {
          #       path = "${config.home.homeDirectory}/Games/games/ludusavi";
          #     };
          #     roots = [
          #       {
          #         path = "${config.xdg.configHome}/heroic";
          #         store = "heroic";
          #       }
          #       {
          #         path = "${config.home.homeDirectory}/Games/Heroic";
          #         store = "heroic";
          #       }
          #       {
          #         path = "${config.xdg.dataHome}/lutris";
          #         store = "lutris";
          #       }
          #       {
          #         path = "${config.home.homeDirectory}/Games/Bottles/Battle.net";
          #         store = "otherWine";
          #       }
          #       {
          #         path = "${config.home.homeDirectory}/Games/Bottles/GOG-Galaxy";
          #         store = "otherWine";
          #       }
          #       {
          #         path = "${config.home.homeDirectory}/Games/Bottles/itch.io";
          #         store = "otherWine";
          #       }
          #       {
          #         path = "${config.home.homeDirectory}/Games/Bottles/Uplay";
          #         store = "otherWine";
          #       }
          #       {
          #         path = "${config.xdg.dataHome}/Steam";
          #         store = "steam";
          #       }
          #       {
          #         path = "${config.home.homeDirectory}/Games/SteamLibrary";
          #         store = "steam";
          #       }
          #     ];
          #     theme = "dark";
          #   };
          # };
          wayland-pipewire-idle-inhibit = {
            enable = true;
            settings = {
              verbosity = "WARN";
              media_minimum_duration = 5;
              idle_inhibitor = "d-bus";
              sink_whitelist = [
                { name = "Browser"; }
                { name = "Game"; }
                { name = "Music"; }
              ];
            };
          };
        };
        # systemd.user.timers.ludusavi = lib.mkForce {
        #   Install.WantedBy = [ "timers.target" ];
        #   Timer = {
        #     OnBootSec = "2min";
        #     OnUnitActiveSec = "24h";
        #   };
        # };
        # xdg = {
        #   desktopEntries = {
        #     gog-galaxy =
        #       let
        #         icon = pkgs.fetchurl {
        #           url = "https://docs.gog.com/_assets/galaxy_icon_rgb.svg";
        #           hash = "sha256-SpaFaSK05Uq534qPYV7s7/vzexZmMnpJiVtOsbCtjvg=";
        #         };
        #       in
        #       {
        #         name = "GOG Galaxy";
        #         comment = "Launch GOG Galaxy using Bottles.";
        #         exec = "flatpak run --command=bottles-cli com.usebottles.bottles run -p \"GOG Galaxy\" -b \"GOG Galaxy\" -- %u";
        #         icon = "${icon}";
        #         categories = [ "Game" ];
        #         noDisplay = false;
        #         startupNotify = true;
        #         settings = {
        #           StartupWMClass = "GOG Galaxy";
        #         };
        #       };
        #     itch = {
        #       name = "itch";
        #       comment = "Install and play itch.io games easily";
        #       exec = "env PULSE_SINK=Game obs-gamecapture mangohud itch";
        #       icon = "itch";
        #       categories = [ "Game" ];
        #     };
        #   };
        # };
      };
  };
}
