#!/usr/bin/env bash

set -euo pipefail

. /app/env.sh

: "${SC_CAPTURE_HOST:=proxy}"
: "${SC_CAPTURE_PORT:=8080}"
: "${SC_CAPTURE_PATH:=/live/1}"
: "${SC_CAPTURE_DISPLAY:=44}"
: "${SC_CAPTURE_FPS:=30}"
: "${SC_CAPTURE_RES:=1920x1080}"

file_env 'SC_CAPTURE_USER'
file_env 'SC_CAPTURE_PASSWORD'

export DISPLAY=":${SC_CAPTURE_DISPLAY}"

xvfb-run --listen-tcp --server-num "${SC_CAPTURE_DISPLAY}" --auth-file /tmp/xvfb.auth \
  -s "-ac -screen 0 1920x1080x24" \
  firefox &

ffmpeg \
  -f x11grab -i ":${SC_CAPTURE_DISPLAY}" \
  -video_size "${SC_CAPTURE_RES}" -framerate "${SC_CAPTURE_FPS}" -codec:v libx264 -preset ultrafast \
  -f flv "rtmp:${SC_CAPTURE_HOST}:${SC_CAPTURE_PORT}${SC_CAPTURE_PATH}"
