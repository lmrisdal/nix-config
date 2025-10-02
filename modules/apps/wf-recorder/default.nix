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
    environment.systemPackages = with pkgs; [
      wf-recorder
      slurp
      (pkgs.writeShellScriptBin "start-screen-recording2" ''
        OUTPUT_DIR="/home/${username}/Videos/Recordings"
        mkdir -p "$OUTPUT_DIR"

        # check if wf-recorder or wl-screenrec is already running, if so run stop-screen-recording
        if pgrep -x wf-recorder >/dev/null || pgrep -x wl-screenrec >/dev/null; then
          stop-screen-recording
          exit 0
        fi

        local filename="$OUTPUT_DIR/$(date +'%Y-%m-%d_%H-%M-%S').mp4"
        # wl-screenrec $AUDIO -f "$filename" --ffmpeg-encoder-options="-c:v libx264 -crf 23 -preset medium -movflags +faststart" "$@" &
        wf-recorder --audio -f "$filename" -c libx264 -p crf=23 -p preset=medium -p movflags=+faststart "$@" &
        notify-send "Started screen recording" -i video-display

        # toggle_screenrecording_indicator
      '')
      (pkgs.writeShellScriptBin "start-screen-recording" ''
        OUTPUT_DIR="/home/${username}/Videos/Recordings"
        mkdir -p "$OUTPUT_DIR"

        # Selects region or output
        SCOPE="$1"

        # Selects audio inclusion or not
        AUDIO=$([[ $2 == "audio" ]] && echo "--audio=alsa_card.usb-NuForce__Inc._NuForce___DAC_2-01")

        start_screenrecording() {
          local filename="$OUTPUT_DIR/$(date +'%Y-%m-%d_%H-%M-%S').mp4"

          #wl-screenrec $AUDIO -f "$filename" --ffmpeg-encoder-options="-c:v libx264 -crf 23 -preset medium -movflags +faststart" "$@" &
          wf-recorder $AUDIO -f "$filename" -c libx264 -p crf=23 -p preset=medium -p movflags=+faststart "$@" &

          #toggle_screenrecording_indicator
        }

        stop_screenrecording() {
          pkill -x wl-screenrec
          pkill -x wf-recorder

          notify-send "Screen recording saved to $OUTPUT_DIR" -t 2000

          #sleep 0.2 # ensures the process is actually dead before we check
          #toggle_screenrecording_indicator
        }

        toggle_screenrecording_indicator() {
          pkill -RTMIN+8 waybar
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
    ];
    home-manager.users.${username} = {
    };
  };
}
