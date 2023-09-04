#!/usr/bin/env bash

set -euo pipefail

: "${SC_CAPTURE_CONTROL_HOST?}"
: "${SC_CAPTURE_FPS?}"
: "${SC_CAPTURE_RENDER?}"
: "${SC_CAPTURE_SCREEN_WIDTH?}"
: "${SC_CAPTURE_SCREEN_HEIGHT?}"
: "${SC_CAPTURE_TIMING_URL?}"
: "${SC_CAPTURE_DATA?}"

SC_CAPTURE_AUDIO="default"
SC_CAPTURE_DISPLAY=42
SC_CAPTURE_NAME="stream"
SC_CAPTURE_GOP_LEN=2
SC_CAPTURE_GOP=$((SC_CAPTURE_FPS * SC_CAPTURE_GOP_LEN))
SC_CAPTURE_TQ_SIZE=16
SC_CAPTURE_USER_AGENT="strmcp-broadcaster-1.0.0"

DISPLAY=":${SC_CAPTURE_DISPLAY}"
export DISPLAY

echo "-- start sound server"
pulseaudio -D --exit-idle-time=-1 --use-pid-file
PA_PID=$(cat /tmp/pulse-*/pid)
pacmd load-module module-virtual-sink sink_name=v1
pacmd set-default-sink v1
pacmd set-default-source v1.monitor

echo "-- start browser"
rm -rf /tmp/.X*-lock
xvfb-run -l -n "${SC_CAPTURE_DISPLAY}" -e /dev/stdout \
  -s "-screen 0 ${SC_CAPTURE_SCREEN_WIDTH}x${SC_CAPTURE_SCREEN_HEIGHT}x24 -fbdir /tmp -ac -listen tcp -noreset +extension RANDR" \
  firefox --display="${DISPLAY}" --kiosk --private-window --marionette --remote-debugging-port 9222 &
XVFB_PID=$!
sleep 2

echo "-- start capturing"
ffmpeg \
  -re -hide_banner -loglevel error -nostats \
  -vaapi_device "${SC_CAPTURE_RENDER}" \
  \
  -f x11grab \
  -s "${SC_CAPTURE_SCREEN_WIDTH}x${SC_CAPTURE_SCREEN_HEIGHT}" -framerate "${SC_CAPTURE_FPS}" -draw_mouse 0 -thread_queue_size "${SC_CAPTURE_TQ_SIZE}" \
  -i ":${SC_CAPTURE_DISPLAY}" \
  \
  -f pulse \
  -thread_queue_size "${SC_CAPTURE_TQ_SIZE}" \
  -i "${SC_CAPTURE_AUDIO}" \
  \
  -flags +global_header -r "${SC_CAPTURE_FPS}" \
  \
  -pix_fmt yuv420p \
  -vf 'hwupload,scale_vaapi=format=nv12' \
  -c:v h264_vaapi \
  -qp 24 \
  \
  -b:v:0 4500K -maxrate:v:0 4500K \
  \
  -g:v "${SC_CAPTURE_GOP}" -keyint_min:v "${SC_CAPTURE_GOP}" -force_key_frames "expr:gte(t,n_forced*${SC_CAPTURE_GOP_LEN})" -sc_threshold:v 0 \
  \
  -color_primaries bt709 -color_trc bt709 -colorspace bt709 \
  \
  -c:a aac -ar 44100 -b:a 128k \
  \
  -map 0:v:0 \
  -map 1:a:0 \
  \
  -tune zerolatency \
  \
  -adaptation_sets 'id=0,streams=v id=1,streams=a' \
  -seg_duration "${SC_CAPTURE_GOP_LEN}" \
  -remove_at_exit 1 \
  -use_timeline 0 \
  -use_template 1 \
  -streaming 1 \
  -window_size 6 \
  -extra_window_size 0 \
  -frag_type duration \
  -ldash 1 \
  -http_user_agent "${SC_CAPTURE_USER_AGENT}" \
  -http_persistent 1 \
  -utc_timing_url "${SC_CAPTURE_TIMING_URL}" \
  -format_options 'movflags=cmaf' \
  -timeout 0.5 \
  -write_prft 1 \
  -target_latency 3 \
  -hls_playlist 1 \
  -hls_master_name "${SC_CAPTURE_NAME}.m3u8" \
  -media_seg_name 'chunk-$RepresentationID$-$Number%05d$.$ext$' \
  -init_seg_name 'init-$RepresentationID$.$ext$' \
  -f dash \
  "/captures/${SC_CAPTURE_NAME}.mpd" &
FFMPEG_PID=$!

echo "-- start web driver"
geckodriver --connect-existing \
  --host 0.0.0.0 --marionette-port 2828 \
  --log error --log-no-truncate \
  --allow-hosts "${SC_CAPTURE_CONTROL_HOST}" localhost &
SELENIUM_PID=$!

function shutdown {
  kill -s SIGTERM "${FFMPEG_PID}" "${PA_PID}" "${SELENIUM_PID}" "${XVFB_PID}"
  wait
}
trap shutdown SIGTERM SIGINT
wait
