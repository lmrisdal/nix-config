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
    nero-umu.enable = true;
    obs.enable = true;
    steam.enable = true;
    consoleExperience.enable = true;
    vkbasalt.enable = true;
    sunshine.enable = true;

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
          "vm.swappiness" = 100;
          "vm.vfs_cache_pressure" = 50;
        };
      };
    };

    environment.systemPackages = with pkgs; [
      # star citizen
      inputs.nix-citizen.packages.${system}.star-citizen
    ];

    hardware = {
      uinput.enable = true;
      xpadneo.enable = true;
      xone.enable = true; # Xbox controller dongle
    };

    nix.settings = {
      extra-substituters = [
        "https://nix-gaming.cachix.org"
        "https://nix-citizen.cachix.org"
      ];
      extra-trusted-public-keys = [
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
      scx = {
        enable = true;
        package = pkgs.scx.rustscheds;
        scheduler = "scx_lavd";
      };
      udev = {
        packages = with pkgs; [
          game-devices-udev-rules
          # https://github.com/CachyOS/CachyOS-Settings/blob/master/usr/lib/udev/rules.d/30-zram.rules
          (writeTextFile {
            name = "30-zram.rules";
            text = ''
              ACTION=="change", KERNEL=="zram0", ATTR{initstate}=="1", SYSCTL{vm.swappiness}="150", RUN+="${pkgs.bash}/bin/bash -c 'echo N > /sys/module/zswap/parameters/enabled'"
            '';
            destination = "/etc/udev/rules.d/30-zram.rules";
          })
          # https://github.com/CachyOS/CachyOS-Settings/blob/master/usr/lib/udev/rules.d/50-sata.rules
          (writeTextFile {
            name = "50-sata.rules";
            text = ''
              ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_policy}="*", ATTR{link_power_management_policy}="max_performance"
            '';
            destination = "/etc/udev/rules.d/50-sata.rules";
          })
          # https://github.com/CachyOS/CachyOS-Settings/blob/master/usr/lib/udev/rules.d/60-ioschedulers.rules
          (writeTextFile {
            name = "60-ioschedulers.rules";
            destination = "/etc/udev/rules.d/60-ioschedulers.rules";
            text = ''
              # HDD
              ACTION!="remove", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", \
                  ATTR{queue/scheduler}="bfq"
              # SSD
              ACTION!="remove", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", \
                  ATTR{queue/scheduler}="adios"
              # NVMe SSD
              ACTION!="remove", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", \
                  ATTR{queue/scheduler}="adios"
            '';
          })
          # https://github.com/CachyOS/CachyOS-Settings/blob/master/usr/lib/udev/rules.d/69-hdparm.rules
          (writeTextFile {
            name = "69-hdparm.rules";
            text = ''
              ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", RUN+="${hdparm}/bin/hdparm -B 254 -S 0 /dev/%k"
            '';
            destination = "/etc/udev/rules.d/69-hdparm.rules";
          })
          (writeTextFile {
            name = "70-easysmx.rules";
            text = ''
              # EasySMX X05
              SUBSYSTEM=="usb", ATTR{idProduct}=="0091", ATTR{idVendor}=="2f24", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
            '';
            destination = "/etc/udev/rules.d/70-easysmx.rules";
          })
          (writeTextFile {
            name = "70-gamesir.rules";
            text = ''
              # GameSir Cyclone 2 Wireless Controller; USB
              ## Nintendo Switch
              SUBSYSTEM=="usb", ATTR{idProduct}=="2009", ATTR{idVendor}=="057e", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
              ## D-input/Sony
              SUBSYSTEM=="usb", ATTR{idProduct}=="09cc", ATTR{idVendor}=="054c", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
              ## X-input/XBOX
              SUBSYSTEM=="usb", ATTR{idProduct}=="1053", ATTR{idVendor}=="3537", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
              # GameSir Cyclone 2 Wireless Controller; 2.4GHz
              ## X-input/XBOX
              SUBSYSTEM=="usb", ATTR{idProduct}=="100b", ATTR{idVendor}=="3537", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
              # GameSir Cyclone 2 Wireless Controller; Bluetooth
              SUBSYSTEM=="input", ATTR{idProduct}=="8100", ATTR{idVendor}=="054c", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
            '';
            destination = "/etc/udev/rules.d/70-gamesir.rules";
          })
          (writeTextFile {
            name = "70-8bitdo.rules";
            text = ''
              # 8BitDo Arcade Stick; Bluetooth (X-mode)
              SUBSYSTEM=="input", ATTRS{name}=="8BitDo Arcade Stick", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
              # 8BitDo Ultimate 2.4G Wireless  Controller; USB/2.4Ghz
              ## X-mode
              SUBSYSTEM=="usb", ATTR{idProduct}=="3106", ATTR{idVendor}=="2dc8", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
              ## D-mode
              SUBSYSTEM=="usb", ATTR{idProduct}=="3012", ATTR{idVendor}=="2dc8", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
              # 8BitDo Ultimate 2C Wireless Controller; USB/2.4GHz
              SUBSYSTEM=="usb", ATTR{idProduct}=="310a", ATTR{idVendor}=="2dc8", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
            '';
            destination = "/etc/udev/rules.d/70-8bitdo.rules";
          })
          # https://github.com/starcitizen-lug/knowledge-base/wiki/Sticks,-Throttles,-&-Pedals
          (writeTextFile {
            name = "70-flight-stick.rules";
            text = ''
              # Virpil
              KERNEL=="hidraw*", ATTRS{idVendor}=="3344", ATTRS{idProduct}=="*", MODE="0660", TAG+="uaccess"
              ## Virpil Rudder Pedals
              ACTION=="add", SUBSYSTEM=="input", KERNEL=="event*", \
                ENV{ID_VENDOR_ID}=="3344", ENV{ID_MODEL_ID}=="01f8", \
                RUN+="${linuxConsoleTools}/bin/evdev-joystick --e %E{DEVNAME} --d 0"
              # VKB
              KERNEL=="hidraw*", ATTRS{idVendor}=="231d", ATTRS{idProduct}=="*", MODE="0660", TAG+="uaccess"
              ## VKB SEM
              ACTION=="add", SUBSYSTEM=="input", KERNEL=="event*", \
                ENV{ID_VENDOR_ID}=="231d", ENV{ID_MODEL_ID}=="2204", \
                RUN+="${linuxConsoleTools}/bin/evdev-joystick --e %E{DEVNAME} --d 0" 
              ## VKB Gunfighter L
              ACTION=="add", SUBSYSTEM=="input", KERNEL=="event*", \
                ENV{ID_VENDOR_ID}=="231d", ENV{ID_MODEL_ID}=="0127", \
                RUN+="${linuxConsoleTools}/bin/evdev-joystick --e %E{DEVNAME} --d 0" 
              ## VKB Gunfighter R
              ACTION=="add", SUBSYSTEM=="input", KERNEL=="event*", \
                ENV{ID_VENDOR_ID}=="231d", ENV{ID_MODEL_ID}=="0126", \
                RUN+="${linuxConsoleTools}/bin/evdev-joystick --e %E{DEVNAME} --d 0" 
            '';
            destination = "/etc/udev/rules.d/70-vkb.rules";
          })
          (writeTextFile {
            name = "ntsync-udev-rules";
            text = ''KERNEL=="ntsync", MODE="0660", TAG+="uaccess"'';
            destination = "/etc/udev/rules.d/70-ntsync.rules";
          })
          # https://wiki.archlinux.org/title/Gamepad#Motion_controls_taking_over_joypad_controls_and/or_causing_unintended_input_with_joypad_controls
          (writeTextFile {
            name = "51-disable-DS3-and-DS4-motion-controls.rules";
            text = ''
              SUBSYSTEM=="input", ATTRS{name}=="*Controller Motion Sensors", RUN+="${coreutils}/bin/rm %E{DEVNAME}", ENV{ID_INPUT_JOYSTICK}=""
            '';
            destination = "/etc/udev/rules.d/51-disable-DS3-and-DS4-motion-controls.rules";
          })
          # https://reddit.com/r/linux_gaming/comments/1fu4ggk/can_someone_explain_dualsense_to_me/lpwxv12/?context=3#lpwxv12
          (writeTextFile {
            name = "51-disable-dualsense-sound-and-vibration.rules";
            text = ''
              KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", MODE="0660", TAG+="uaccess"
              KERNEL=="hidraw*", KERNELS=="*054C:0CE6*", MODE="0660", TAG+="uaccess"
              ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", ENV{PULSE_IGNORE}="1", ENV{ACP_IGNORE}="1"
            '';
            destination = "/etc/udev/rules.d/51-disable-dualsense-sound-and-vibration.rules";
          })
          # https://github.com/CachyOS/CachyOS-Settings/blob/master/usr/lib/udev/rules.d/71-nvidia.rules
          (writeTextFile {
            name = "71-nvidia.rules";
            text = ''
              # Enable runtime PM for NVIDIA VGA/3D controller devices on driver bind
              ACTION=="add|bind", SUBSYSTEM=="pci", DRIVERS=="nvidia", \
                  ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", \
                  TEST=="power/control", ATTR{power/control}="auto"
              # Disable runtime PM for NVIDIA VGA/3D controller devices on driver unbind
              ACTION=="remove|unbind", SUBSYSTEM=="pci", DRIVERS=="nvidia", \
                  ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", \
                  TEST=="power/control", ATTR{power/control}="on"
            '';
            destination = "/etc/udev/rules.d/71-nvidia.rules";
          })
        ];
      };
    };

    systemd = {
      settings.Manager = {
        DefaultLimitNOFILE = 1048576;
      };
      tmpfiles = {
        rules = [
          # AMD V-Cache
          # https://wiki.cachyos.org/configuration/general_system_tweaks/#amd-3d-v-cache-optimizer
          "w /sys/bus/platform/drivers/amd_x3d_vcache/AMDI0101:00/amd_x3d_mode - - - - cache"
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
        services = {
          flatpak = {
            overrides = {
              global = {
                Environment = {
                  PULSE_SINK = "Game";
                };
              };
              "info.cemu.Cemu" = {
                Context = {
                  filesystems = [
                    "!home"
                    "${config.home.homeDirectory}/Games/ROMs/wiiu/"
                  ];
                };
              };
              "io.github.ryubing.Ryujinx" = {
                Context = {
                  filesystems = [
                    "!home"
                    "${config.home.homeDirectory}/Games/ROMs/switch/"
                  ];
                };
              };
              "net.kuribo64.melonDS" = {
                Context = {
                  filesystems = [
                    "!home"
                    "${config.home.homeDirectory}/Games/ROMS/ds/"
                  ];
                };
              };
              "net.pcsx2.PCSX2" = {
                Context = {
                  filesystems = [
                    "!home"
                    "${config.home.homeDirectory}/Games/ROMS/ps2/"
                  ];
                };
              };
              "net.rpcs3.RPCS3" = {
                Context = {
                  filesystems = [
                    "!home"
                    "${config.home.homeDirectory}/Games/ROMS/ps3/"
                  ];
                };
              };
              "org.duckstation.DuckStation" = {
                Context = {
                  filesystems = [
                    "!home"
                    "${config.home.homeDirectory}/Games/ROMS/psx/"
                  ];
                };
              };
              "net.shadps4.shadPS4" = {
                Context = {
                  filesystems = [
                    "!home"
                    "${config.home.homeDirectory}/Games/ROMS/ps4/"
                  ];
                };
              };
              "org.DolphinEmu.dolphin-emu" = {
                Context = {
                  filesystems = [
                    "!home"
                    "${config.home.homeDirectory}/Games/ROMS/wii/"
                    "${config.home.homeDirectory}/Games/ROMS/gc/"
                  ];
                };
              };
              "io.github.Faugus.faugus-launcher" = {
                Context = {
                  filesystems = [
                    "!home"
                    "${config.home.homeDirectory}/Games"
                    "xdg-data/Steam"
                    "/mnt/vault101/data/Games"
                  ];
                };
              };
              "org.easyrpg.player" = {
                Context = {
                  filesystems = [
                    "${config.home.homeDirectory}/Games/ROMS/rpg/"
                    "!home"
                    "!host"
                  ];
                  shared = "network"; # obs-gamecapture
                };
                Environment = {
                  RPG2K_RTP_PATH = "${config.home.homeDirectory}/Games/Emulator/rpg-maker/RTP/2000";
                  RPG2K3_RTP_PATH = "${config.home.homeDirectory}/Games/Emulator/rpg-maker/RTP/2003";
                };
              };
            };
            packages = [
              "app.xemu.xemu"
              "info.cemu.Cemu"
              "io.github.ryubing.Ryujinx"
              "net.kuribo64.melonDS"
              "net.rpcs3.RPCS3"
              "org.DolphinEmu.dolphin-emu"
              "org.duckstation.DuckStation"
              "org.easyrpg.player"
              "io.github.Faugus.faugus-launcher"
              "net.pcsx2.PCSX2"
              "net.shadps4.shadPS4"
            ];
          };
          ludusavi = {
            enable = true;
            backupNotification = true;
            settings = {
              backup = {
                path = "/mnt/vault101/lars/saves/ludusavi";
                format = {
                  chosen = "zip";
                  zip.compression = "deflate";
                };
              };
              customGames = [
                {
                  name = "Dolphin-Emu";
                  files = [
                    "${config.xdg.dataHome}/dolphin-emu/StateSaves"
                    "${config.home.homeDirectory}/.var/app/org.DolphinEmu.dolphin-emu/data/dolphin-emu/StateSaves"
                  ];
                }
                {
                  name = "Duckstation";
                  files = [
                    "${config.xdg.configHome}/duckstation/memcards"
                    "${config.xdg.configHome}/duckstation/savestates"
                    "${config.home.homeDirectory}/.var/app/org.duckstation.DuckStation/config/duckstation/memcards"
                    "${config.home.homeDirectory}/.var/app/org.duckstation.DuckStation/config/duckstation/savestates"
                  ];
                }
                {
                  name = "PCSX2";
                  files = [
                    "${config.xdg.configHome}/PCSX2/memcards"
                    "${config.xdg.configHome}/PCSX2/sstates"
                    "${config.home.homeDirectory}/.var/app/net.pcsx2.PCSX2/config/PCSX2/memcards"
                    "${config.home.homeDirectory}/.var/app/net.pcsx2.PCSX2/config/PCSX2/sstates"
                  ];
                }
              ];
              restore = {
                path = "/mnt/vault101/lars/saves/ludusavi";
              };
              roots = [
                {
                  path = "${config.xdg.configHome}/heroic";
                  store = "heroic";
                }
                {
                  path = "${config.home.homeDirectory}/Games/Heroic";
                  store = "heroic";
                }
                {
                  path = "${config.xdg.dataHome}/lutris";
                  store = "lutris";
                }
                {
                  path = "${config.home.homeDirectory}/Games/Lutris";
                  store = "lutris";
                }
                # {
                #   path = "${config.home.homeDirectory}/Games/Bottles/Battle.net";
                #   store = "otherWine";
                # }
                # {
                #   path = "${config.home.homeDirectory}/Games/Bottles/GOG-Galaxy";
                #   store = "otherWine";
                # }
                # {
                #   path = "${config.home.homeDirectory}/Games/Bottles/itch.io";
                #   store = "otherWine";
                # }
                # {
                #   path = "${config.home.homeDirectory}/Games/Bottles/Uplay";
                #   store = "otherWine";
                # }
                {
                  path = "${config.xdg.dataHome}/Steam";
                  store = "steam";
                }
                {
                  path = "${config.home.homeDirectory}/Games/SteamLibrary";
                  store = "steam";
                }
              ];
              theme = "dark";
            };
          };
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
        systemd.user.timers.ludusavi = lib.mkForce {
          Install.WantedBy = [ "timers.target" ];
          Timer = {
            OnBootSec = "2min";
            OnUnitActiveSec = "24h";
          };
        };
      };
  };
}
