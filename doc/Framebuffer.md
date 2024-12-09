# Playing with framebuffer

- Dump one frame: /ac_lib/lib/third_bin/ffmpeg -f fbdev -i /dev/fb0 -frames:v 1 -y /useremain/test.bmp
- Display one frame: /ac_lib/lib/third_bin/ffmpeg -i /useremain/test.bmp -pix_fmt bgra -f fbdev /dev/fb0
- Draw things
    /ac_lib/lib/third_bin/ffmpeg -i /useremain/test.bmp -vf "drawbox=x=16:y=16:w=32:h=ih-32:t=fill:color=black@0.5" -f fbdev /dev/fb0
- Progressbar:
    /ac_lib/lib/third_bin/ffmpeg -i /useremain/test.bmp -vf "drawbox=x=16:y=16:w=32:h=ih-32:t=fill:color=black,drawbox=x=20:y=20:w=24:h=(ih-32)*0.4:t=fill:color=white" -f fbdev /dev/fb0