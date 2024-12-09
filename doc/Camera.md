If you try to access `x.x.x.x/webcam/?action=stream` from your browser and you get a Bad Gateway, it might mean mjpg-streamer is not running properly.
You also mentionned blue light, so it might not be the official Anycubic camera and might behave differently from mine.

Here are some debugging steps:

### Check if mjpg is running
After a reboot, use SSH / ADB and do a `ps | grep mjpg`, and then post the results here. For mine:
```
root@Rockchip:~# ps | grep mjpg
  431 root      1216 S    {exe} ash /useremain/home/ytka/mjpg-streamer.sh
  436 root     32108 S    /useremain/dist/mjpg-streamer/mjpg_streamer -i input
 3208 root      1208 S    grep mjpg
```

### Then check if the startup script is working
Using SSH / ADB, try to manually run `/useremain/home/ytka/mjpg-streamer.sh`
It should look like:
```
root@Rockchip:~# /useremain/home/ytka/mjpg-streamer.sh
killall: gkcam: no process killed
MJPG Streamer Version: git rev: 310b29f4a94c46652b20c4b7b6e5cf24e532af39
 i: Using V4L2 device.: /dev/video10
 i: Desired Resolution: 1280 x 720
 i: Frames Per Second.: -1
 i: Format............: JPEG
 i: TV-Norm...........: DEFAULT
 o: www-folder-path......: /useremain/dist/mjpg-streamer/www/
 o: HTTP TCP port........: 8080
 o: HTTP Listen Address..: (null)
 o: username:password....: disabled
 o: commands.............: enabled
```

### If not, try running mjpg-streamer manually
Run `/useremain/dist/mjpg-streamer/mjpg_streamer -i "input_uvc.so -d /dev/video10 -n -r 1280x720" -o "output_http.so -w /useremain/dist/mjpg-streamer/www"`

### Else, post your webcam info here
Run `v4l2-ctl --list-devices` to see your webcam, for example with mine:
```
root@Rockchip:~# v4l2-ctl --list-devices
rkisp-statistics (platform: rkisp):
        /dev/video8
        /dev/video9

rkisp_mainpath (platform:rkisp-vir0):
        /dev/video0
        /dev/video1
        /dev/video2
        /dev/video3
        /dev/video4
        /dev/video5
        /dev/video6
        /dev/video7

USB 2.0 Camera: USB Camera (usb-xhci-hcd.0.auto-1.2):
        /dev/video10
        /dev/video11
```

Identify the first path under `USB Camera`, then run `v4l2-ctl -w -d /dev/videoX --list-formats-ext` (it would be `/dev/video10` for me) and post the results here. For mine:
```
root@Rockchip:~# v4l2-ctl -w -d /dev/video10 --list-formats-ext
ioctl: VIDIOC_ENUM_FMT
        Index       : 0
        Type        : Video Capture
        Pixel Format: 'MJPG' (compressed)
        Name        : Motion-JPEG
                Size: Discrete 960x720
                        Interval: Discrete 0.033s (30.000 fps)
                Size: Discrete 1280x720
                        Interval: Discrete 0.033s (30.000 fps)
                Size: Discrete 1024x576
                        Interval: Discrete 0.033s (30.000 fps)
                Size: Discrete 864x480
....
```
