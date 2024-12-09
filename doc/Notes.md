# Notes
-------

Useful commands:
- lsof -iP
- v4l2-ctl --list-devices
- v4l2-ctl -w -d /dev/video10 --list-formats-ext


Interesting files:
- /userdata/app/gk > Configuration files, APIs, ...
- /userdata/app/gk/config > Configuration files, APIs, ...
- /tmp > Logs
- /useremain/home/ytka/printer_data/logs/moonraker.log > Moonraker logs
- /useremain/dist/nginx/conf > Ngix config
- /ac_lib/lib/third_bin > ffmpeg, mosquitto, ...

Docker:
- docker run --privileged --rm tonistiigi/binfmt --install all
- docker run --rm -it --platform linux/arm/v7 arm32v7/debian:12.8
- docker run --rm -it -v .\work:/work -v .\work\bin:/usr/local/bin builder-armv7l


To do:
    x Fork https://github.com/utkabobr/DuckPro-Kobra3
    x Add double beep after installation
    x Add Fluidd
    - Change model back to normal : /useremain/home/ytka/printer_data/config/printer.cfg
    x Add mjpg-streamer
    - Add ntp date sync
    - Show print screen on Moonraker print




Work in progress
----------------

root@Rockchip:~# netstat -tuln
    Proto Local Address          
    tcp   0.0.0.0:80             | Nginx
    tcp   0.0.0.0:5555           | ADB
    tcp   127.0.0.1:5037         | ADB
    tcp   0.0.0.0:7125           | Moonraker
    tcp   0.0.0.0:22             | SSH
    tcp   0.0.0.0:9883           | gkapi (HTTPS)
    tcp   192.168.1.147:18910    | gkapi
    tcp   0.0.0.0:2883           | gkapi (MQTT)
    tcp   0.0.0.0:18086          | gkapi (gkui)
    tcp   0.0.0.0:18088          | gkcam
    tcp   127.0.0.1:3893         | gkcam
    udp   0.0.0.0:10086          | gkcam
    udp   0.0.0.0:1900           | gkapi (SSDP)


Weird script from https://stackoverflow.com/a/35590955
    tcp pid:361 local=0.0.0.0:    2883 remote=0.0.0.0:    0 inode:6193 exe=/userdata/app/gk/gkapi
    tcp pid:361 local=0.0.0.0:    18086 remote=0.0.0.0:    0 inode:5530 exe=/userdata/app/gk/gkapi
    tcp pid:429 local=0.0.0.0:    18088 remote=0.0.0.0:    0 inode:5904 exe=/userdata/app/gk/gkcam
    tcp pid:214 local=1.0.0.127:    5037 remote=0.0.0.0:    0 inode:5014 exe=/usr/bin/adbd
    tcp pid:214 local=0.0.0.0:    5555 remote=0.0.0.0:    0 inode:5026 exe=/usr/bin/adbd
    tcp pid:429 local=1.0.0.127:    3893 remote=0.0.0.0:    0 inode:5913 exe=/userdata/app/gk/gkcam
    tcp pid:358 local=0.0.0.0:    7125 remote=0.0.0.0:    0 inode:5647 exe=/useremain/dist/bin/python3.11
    tcp pid:465 local=0.0.0.0:    22 remote=0.0.0.0:    0 inode:5938 exe=/ac_lib/lib/openssh/sbin/sshd
    tcp pid:361 local=0.0.0.0:    9883 remote=0.0.0.0:    0 inode:6192 exe=/userdata/app/gk/gkapi
    tcp pid:361 local=147.1.168.192:    18910 remote=0.0.0.0:    0 inode:6186 exe=/userdata/app/gk/gkapi
    udp pid:429 local=0.0.0.0:    10086 remote=0.0.0.0:    0 inode:5929 exe=/userdata/app/gk/gkcam
    udp pid:361 local=0.0.0.0:    1900 remote=0.0.0.0:    0 inode:6184 exe=/userdata/app/gk/gkapi

    tcp pid:361 local=1.0.0.127:    9883 remote=1.0.0.127:    47624 inode:6206 exe=/userdata/app/gk/gkapi               | gkapi > gkapi:9883
    tcp pid:499 local=147.1.168.192:    22 remote=2.1.168.192:    52726 inode:6068 exe=/ac_lib/lib/openssh/sbin/sshd    | 192.168.1.2 > SSH
    tcp pid:429 local=1.0.0.127:    48624 remote=1.0.0.127:    18086 inode:5905 exe=/userdata/app/gk/gkcam              | gkcam > gkapi:18086
    tcp pid:362 local=1.0.0.127:    48618 remote=1.0.0.127:    18086 inode:5686 exe=/userdata/app/gk/K3SysUi            | K3SysUi > gkapi:18086
    tcp pid:361 local=147.1.168.192:    9883 remote=2.1.168.192:    37328 inode:9407 exe=/userdata/app/gk/gkapi         | 192.168.1.2 > gkapi:9883
    tcp pid:361 local=147.1.168.192:    9883 remote=2.1.168.192:    37312 inode:9353 exe=/userdata/app/gk/gkapi         | 192.168.1.2 > gkapi:9883
    tcp pid:429 local=147.1.168.192:    18088 remote=2.1.168.192:    39840 inode:5910 exe=/userdata/app/gk/gkcam        | 192.168.1.2 > gkcam:18088


### Moonraker packages

docker run --privileged --rm tonistiigi/binfmt --install all
docker run --rm -it --platform linux/arm/v7 -v C:\Projects\Git\jbatonnet\Rinkhals:/rinkhals arm32v7/debian:12.8

apt update
apt install -y build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python3-openssl git

wget https://www.python.org/ftp/python/3.12.7/Python-3.12.7.tgz
tar -xf Python-3.12.7.tgz

cd Python-3.12.7
./configure --enable-optimizations
make -j 6
make altinstall

apt install -y libjpeg-dev libsodium23ls /ri        

wget https://bootstrap.pypa.io/get-pip.py
python3.12 get-pip.py

python3.12 -m pip install -r /rinkhals/files/target/usr/share/moonraker/scripts/moonraker-requirements.txt
python3.12 -m pip install websockets paho-mqtt aiohttp

HOME=/rinkhals/files/target/home/rinkhals python3.12 /rinkhals/files/target/usr/share/moonraker/moonraker/moonraker.py

rm -rf /rinkhals/files/target/usr/lib/python3.12/sites-packages/*
cp -r /usr/local/lib/python3.12/site-packages/* /rinkhals/files/target/usr/lib/python3.12/sites-packages


