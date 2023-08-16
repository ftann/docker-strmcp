#!/usr/bin/env bash

set -euo pipefail

: "${SC_CAPTURE_CONTROL_HOST?}"
: "${SC_CAPTURE_FPS?}"
: "${SC_CAPTURE_RENDER?}"
: "${SC_CAPTURE_FPS_INPUT:=${SC_CAPTURE_FPS}}"
: "${SC_CAPTURE_SCREEN_WIDTH?}"
: "${SC_CAPTURE_SCREEN_HEIGHT?}"
: "${SC_CAPTURE_TIMING_URL?}"
: "${SC_CAPTURE_DATA?}"

SC_CAPTURE_AUDIO="default"
SC_CAPTURE_DISPLAY=42
SC_CAPTURE_NAME="stream"
SC_CAPTURE_TQ_SIZE=32
SC_CAPTURE_USER_AGENT="strmcp-broadcaster-1.0.0"

DISPLAY=":${SC_CAPTURE_DISPLAY}"
export DISPLAY

echo "-- start browser"
XPRA_SESSION_DIR="/tmp"
XDG_RUNTIME_DIR="/tmp/capture"
export XPRA_SESSION_DIR XDG_RUNTIME_DIR
rm -rf /tmp/.X*-lock
xpra start "${DISPLAY}" --daemon=no \
  --start-child="firefox --kiosk --private-window --marionette --remote-debugging-port 9222" &
XPRA_PID=$!

#/usr/bin/Xorg -noreset -nolisten tcp \
#  +extension GLX +extension RANDR +extension RENDER \
#  -auth "${XAUTHORITY}" \
#  -logfile auto/Xorg.${DISPLAY}.log \
#  -configdir "${HOME}/.xpra/xorg.conf.d" \
#  -config /etc/xpra/xorg.conf

sleep 3

#xvfb-run -l -n "${SC_CAPTURE_DISPLAY}" -e /dev/stdout \
#  -s "-screen 0 ${SC_CAPTURE_SCREEN_WIDTH}x${SC_CAPTURE_SCREEN_HEIGHT}x24 -fbdir /tmp -ac -listen tcp -noreset +extension RANDR" \
#  firefox --display="${DISPLAY}" --kiosk --private-window --marionette --remote-debugging-port 9222 &

echo "-- start capturing"
timestamp="$(date +%s)"
mkdir -p "${SC_CAPTURE_DATA}/${timestamp}"
ffmpeg \
  -re -hide_banner -loglevel error -nostats \
  -vaapi_device /dev/dri/renderD128 \
  \
  -f x11grab \
  -s "${SC_CAPTURE_SCREEN_WIDTH}x${SC_CAPTURE_SCREEN_HEIGHT}" -framerate "${SC_CAPTURE_FPS_INPUT}" -draw_mouse 0 -thread_queue_size "${SC_CAPTURE_TQ_SIZE}" \
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
  -g:v "${SC_CAPTURE_FPS}" -keyint_min:v "${SC_CAPTURE_FPS}" -sc_threshold:v 0 \
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
  -adaptation_sets 'id=0,seg_duration=6.006,streams=v id=1,seg_duration=6.006,streams=a' \
  -remove_at_exit 1 \
  -use_timeline 0 \
  -streaming 1 \
  -window_size 3 \
  -frag_type every_frame \
  -ldash 1 \
  -http_user_agent "${SC_CAPTURE_USER_AGENT}" \
  -http_persistent 1 \
  -utc_timing_url "http://${SC_CAPTURE_TIMING_URL}"\
  -format_options 'movflags=cmaf' \
  -timeout 0.5 \
  -write_prft 1 \
  -target_latency '3.0' \
  -hls_playlist 1 \
  -hls_master_name "${SC_CAPTURE_NAME}.m3u8" \
  -media_seg_name "${timestamp}/"'chunk-$RepresentationID$-$Number%05d$.$ext$' \
  -init_seg_name "${timestamp}/"'init-$RepresentationID$.$ext$' \
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
  kill -s SIGTERM "${FFMPEG_PID}" "${SELENIUM_PID}" "${XPRA_PID}"
  wait
}
trap shutdown SIGTERM SIGINT
wait
