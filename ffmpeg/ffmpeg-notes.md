# remove audio from mp4
```
$ ffmpeg -i video.mp4 -vn -acodec copy output-audio.aac
```
# export audio from mp4
```
$ ffmpeg -i video.mp4 -vn -acodec copy output-audio.aac
```
# split part of video
```
$ ffmpeg -ss 00:00:00 -to 00:03:29 -i input.mp4 -c copy output.mp4
```