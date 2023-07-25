FROM alpine:3.18.2 AS builder

RUN apk add --no-cache \
    bash nodejs npm

COPY app/ /src/

WORKDIR /src/

RUN npm install && \
    npm run build

FROM alpine:3.18.2

RUN apk add --no-cache \
    bash nodejs && \
    apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing/ \
    geckodriver

RUN addgroup -g 666 control && \
    adduser -D -h /control -s /sbin/nologin -G control -u 666 control

COPY root/ /
COPY --from=builder /src/dist/control.js /app/control.js

ENV SC_CONTROL_DRIVER_HOST="capture" \
    SC_CONTROL_DRIVER_PORT=4444 \
    SC_CAPTURE_SCREEN_WIDTH=1280 \
    SC_CAPTURE_SCREEN_HEIGHT=720

USER control:control

ENTRYPOINT ["/entrypoint.sh"]
