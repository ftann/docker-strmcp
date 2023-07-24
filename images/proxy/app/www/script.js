const video = document.getElementById("video");
const videoSrc = "hls/live/1.m3u8";
// First check for native browser HLS support
if (video.canPlayType("application/vnd.apple.mpegurl")) {
    video.src = videoSrc;
}
// If no native HLS support, check if hls.js is supported
else if (Hls.isSupported()) {
    const hls = new Hls();
    hls.loadSource(videoSrc);
    hls.attachMedia(video);
}
