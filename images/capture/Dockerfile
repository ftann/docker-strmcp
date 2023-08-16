FROM alpine:3.18.2

ARG SC_CAPTURE_DATA="/captures"

EXPOSE 4444

RUN apk add --no-cache \
    bash firefox ffmpeg mesa-dri-gallium mesa-va-gallium pulseaudio pulseaudio-utils xf86-video-dummy xf86-video-amdgpu xf86-video-intel xorg-server tzdata \
    fontconfig freetype font-ubuntu font-misc-misc && \
    apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing/ \
    geckodriver libva-utils virtualgl

RUN touch /tmp/xvfb.auth && \
    mkdir -p /tmp/.X11-unix && \
    chmod 1777 /tmp/.X11-unix

RUN addgroup -g 666 capture && \
    adduser -D -h /tmp/capture -s /sbin/nologin -G capture -u 666 capture && \
    mkdir -p ${SC_CAPTURE_DATA} && \
    chown capture:capture ${SC_CAPTURE_DATA}

#USER capture:capture

COPY root/ /

ENV SC_CAPTURE_CONTROL_HOST="capture" \
    SC_CAPTURE_FPS=30 \
    SC_CAPTURE_RENDER="/dev/dri/renderD128" \
    SC_CAPTURE_SCREEN_WIDTH=1920 \
    SC_CAPTURE_SCREEN_HEIGHT=1080 \
    SC_CAPTURE_TIMING_URL="proxy:8080/time" \
    SC_CAPTURE_DATA=${SC_CAPTURE_DATA}

VOLUME ${SC_CAPTURE_DATA}

HEALTHCHECK CMD ["/health.sh"]

ENTRYPOINT ["/entrypoint.sh"]
