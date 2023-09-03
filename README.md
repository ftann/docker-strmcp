# STRMCP

Capture and broadcast browser content.

## Start

**Only capture**

```shell
docker compose up -d
```

**Enable Wireguard**

```shell
docker compose --profile wg up -d
```

## Open Stream

**[DASH](http://localhost:8080/live/stream.mpd)**

**[HLS](http://localhost:8080/live/stream.m3u8)**

### Trigger control

To restart the control container open the trigger endpoint.

[Trigger](http://localhost:8080/trigger)

## Links

- https://moctodemo.akamaized.net/tools/ffbuilder
- https://cloud.ibm.com/docs/CDN?topic=CDN-how-to-serve-video-on-demand-with-cdn
- https://ffmpeg.org/ffmpeg-formats.html
- https://github.com/Dash-Industry-Forum/dash.js
- https://www.selenium.dev/selenium/docs/api/javascript/index.html
- https://blog.logrocket.com/testing-website-selenium-docker/#running-selenium-tests-firefox
