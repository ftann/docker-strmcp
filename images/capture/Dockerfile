FROM alpine:3.18.2

ENV SC_CAPTURE_HOST="proxy" \
    SC_CAPTURE_PORT=9000 \
    SC_CAPTURE_PATH="/live/1" \
    SC_CAPTURE_FPS=30 \
    SC_CAPTURE_RES="1920x1080"

RUN apk add --no-cache \
    bash chromium chromium-chromedriver firefox ffmpeg tzdata xvfb-run

COPY root/ /

USER nobody:nobody

ENTRYPOINT ["/entrypoint.sh"]
