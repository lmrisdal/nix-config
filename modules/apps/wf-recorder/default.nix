{
  lib,
  config,
  username,
  pkgs,
  ...
}:
let
  cfg = config.wf-recorder;
in
{
  options = {
    wf-recorder = {
      enable = lib.mkEnableOption "Enable wf-recorder in NixOS";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.variables = {
      SCREENRECORD_DIR = "/home/${username}/Videos/Recordings";
    };
    environment.systemPackages = with pkgs; [
      wf-recorder
      slurp
      (pkgs.writeShellScriptBin "start-screen-recording" ''
        OUTPUT_DIR="''${SCREENRECORD_DIR}"
        mkdir -p "$OUTPUT_DIR"

        # Selects region or output
        SCOPE="$1"

        # Selects audio inclusion or not
        #AUDIO=$([[ $2 == "audio" ]] && echo "--audio=alsa_output.usb-NuForce__Inc._NuForce___DAC_2-01")
        AUDIO=$([[ $2 == "audio" ]] && echo "--audio")

        start_screenrecording() {
          local filename="$OUTPUT_DIR/$(date +'%Y-%m-%d_%H-%M-%S').mp4"

          # wl-screenrec: https://github.com/russelltg/wl-screenrec/issues/95
          # wl-screenrec $AUDIO -f "$filename" --ffmpeg-encoder-options="-c:v libx264 -crf 23 -preset medium -movflags +faststart" "$@" &

          wf-recorder $AUDIO -f "$filename" -c libx264 -p crf=23 -p preset=medium -p movflags=+faststart "$@" &
        }

        stop_screenrecording() {
          pkill -x wl-screenrec
          pkill -x wf-recorder

          notify-send "Screen recording saved to $OUTPUT_DIR" -t 2000
        }

        screenrecording_active() {
          pgrep -x wl-screenrec >/dev/null || pgrep -x wf-recorder >/dev/null
        }

        if screenrecording_active; then
          stop_screenrecording
        elif [[ "$SCOPE" == "output" ]]; then
          # output=$(slurp -o) || exit 1
          # start_screenrecording -g "$output"
          start_screenrecording
        else
          region=$(slurp) || exit 1
          start_screenrecording -g "$region"
        fi
      '')
      (pkgs.writeShellScriptBin "stop-screen-recording" ''
        pkill -x wl-screenrec
        pkill -x wf-recorder
        notify-send "Screen recording saved to ''${SCREENRECORD_DIR}" -t 2000
      '')
    ];
    home-manager.users.${username} = {
    };
  };
}
