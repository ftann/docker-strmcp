FROM alpine:3.18.2

EXPOSE 1935 8080

RUN apk add --no-cache \
    nginx nginx-mod-rtmp

COPY root/ /

#USER nobody:nobody

ENTRYPOINT ["/entrypoint.sh"]
