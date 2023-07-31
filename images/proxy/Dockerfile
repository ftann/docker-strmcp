FROM alpine:3.18.2

EXPOSE 8080

ARG SC_CAPTURE_DATA="/captures"

RUN apk add --no-cache \
    bash envsubst nginx nginx-mod-http-js nginx-mod-rtmp

COPY root/ /

ENV SC_CAPTURE_DATA=${SC_CAPTURE_DATA}

RUN SC_CAPTURE_DATA=${SC_CAPTURE_DATA} envsubst '$SC_CAPTURE_DATA' < /nginx.conf > /nginx.conf.tmp && \
    mv /nginx.conf.tmp /nginx.conf

HEALTHCHECK CMD ["/health.sh"]

ENTRYPOINT ["/usr/sbin/nginx"]

CMD ["-g", "daemon off;", "-c", "/nginx.conf"]
