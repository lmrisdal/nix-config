{
  lib,
  config,
  username,
  pkgs,
  vars,
  ...
}:
let
  cfg = config.pipewire;
in
{
  options = {
    pipewire = {
      enable = lib.mkEnableOption "Enable pipewire in NixOS & home-manager";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      alsa-firmware
      alsa-lib
      alsa-plugins
      alsa-tools
      alsa-utils
      pulseaudio
    ];

    # https://github.com/NixOS/nixpkgs/issues/330606
    #hardware.alsa.enablePersistence = true;

    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      jack.enable = true;
      pulse.enable = true;
      extraConfig = {
        pipewire = {
          "10-clock-rate" = {
            "context.properties" = {
              # To make DAC properly work
              "default.clock.allowed-rates" = [
                44100
                48000
                88200
                96000
                176400
                192000
              ];
              "default.clock.quantum" = 512;
              "default.clock.min-quantum" = 512;
              "default.clock.max-quantum" = 512;
            };
          };
          "11-virtual-devices" = {
            "context.modules" =
              [ { } ]
              ++ lib.optionals vars.gaming [
                # Keep playback node.name different from capture node.name so KDE doesn't get confused
                {
                  "name" = "libpipewire-module-loopback";
                  "args" = {
                    "audio.position" = [
                      "FL"
                      "FR"
                    ];
                    "capture.props" = {
                      "media.class" = "Audio/Sink";
                      "node.name" = "Browser";
                      "node.description" = "Browser";
                    };
                    "playback.props" = {
                      "node.name" = "Browser_m";
                      "node.description" = "Browser";
                    };
                  };
                }
                {
                  "name" = "libpipewire-module-loopback";
                  "args" = {
                    "audio.position" = [
                      "FL"
                      "FR"
                    ];
                    "capture.props" = {
                      "media.class" = "Audio/Sink";
                      "node.name" = "Game";
                      "node.description" = "Game";
                    };
                    "playback.props" = {
                      "node.name" = "Game_m";
                      "node.description" = "Game";
                    };
                  };
                }
                {
                  "name" = "libpipewire-module-loopback";
                  "args" = {
                    "audio.position" = [
                      "FL"
                      "FR"
                    ];
                    "capture.props" = {
                      "media.class" = "Audio/Sink";
                      "node.name" = "Live";
                      "node.description" = "Live";
                    };
                    "playback.props" = {
                      "node.name" = "Live_m";
                      "node.description" = "Live";
                    };
                  };
                }
                {
                  "name" = "libpipewire-module-loopback";
                  "args" = {
                    "audio.position" = [
                      "FL"
                      "FR"
                    ];
                    "capture.props" = {
                      "media.class" = "Audio/Sink";
                      "node.name" = "MIDI";
                      "node.description" = "MIDI";
                    };
                    "playback.props" = {
                      "node.name" = "MIDI_m";
                      "node.description" = "MIDI";
                    };
                  };
                }
                {
                  "name" = "libpipewire-module-loopback";
                  "args" = {
                    "audio.position" = [
                      "FL"
                      "FR"
                    ];
                    "capture.props" = {
                      "media.class" = "Audio/Sink";
                      "node.name" = "Music";
                      "node.description" = "Music";
                    };
                    "playback.props" = {
                      "node.name" = "Music_m";
                      "node.description" = "Music";
                    };
                  };
                }
                {
                  "name" = "libpipewire-module-loopback";
                  "args" = {
                    "audio.position" = [
                      "FL"
                      "FR"
                    ];
                    "capture.props" = {
                      "media.class" = "Audio/Sink";
                      "node.name" = "Voice";
                      "node.description" = "Voice";
                    };
                    "playback.props" = {
                      "node.name" = "Voice_m";
                      "node.description" = "Voice";
                    };
                  };
                }
              ];
          };
        };
        pipewire-pulse = {
          "10-resample-quality" = {
            "stream.properties" = {
              "resample.quality" = 10;
            };
          };
        };
      };
      wireplumber = {
        enable = true;
        extraConfig =
          {
            # Static/crackling fix https://wiki.archlinux.org/title/PipeWire#Noticeable_audio_delay_or_audible_pop/crack_when_starting_playback
            "51-disable-suspension" = {
              "monitor.alsa.rules" = [
                {
                  matches = [
                    { "node.name" = "~alsa_output.*"; }
                  ];
                  actions.update-props = {
                    "session.suspend-timeout-seconds" = 0;
                  };
                }
              ];
              "monitor.bluez.rules" = [
                {
                  matches = [
                    { "node.name" = "~bluez_input.*"; }
                    { "node.name" = "~bluez_output.*"; }
                  ];
                  actions.update-props = {
                    "session.suspend-timeout-seconds" = 0;
                  };
                }
              ];
            };
          }
          // lib.optionalAttrs vars.gaming {
            "51-disable-dualsense-audio" = {
              "monitor.alsa.rules" = [
                {
                  matches = [
                    { "alsa.card_name" = "Wireless Controller"; }
                  ];
                  actions.update-props = {
                    "node.disabled" = true;
                  };
                }
              ];
            };
          };
      };
    };

    services.pulseaudio.enable = lib.mkForce false;

    home-manager.users.${username} = { };
  };
}
