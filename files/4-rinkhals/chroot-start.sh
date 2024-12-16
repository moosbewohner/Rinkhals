function log() {
    echo "${*}"
    echo "`date`: ${*}" >> /rinkhals.log
}
function kill_by_name() {
    for i in `ls /proc/*/cmdline 2> /dev/null`; do
        PID=`echo $i | awk -F'/' '{print $3}'`
        CMDLINE=`cat $i` 2>/dev/null

        if echo "$CMDLINE" | grep -q "${*}"; then
            log "Killing $PID ($CMDLINE)"
            kill -9 $PID
        fi
    done
}
function check_by_name() {
    for i in `ls /proc/*/cmdline 2> /dev/null`; do
        CMDLINE=`cat $i` 2>/dev/null

        if echo "$CMDLINE" | grep -q "${*}"; then
            return
        fi
    done

    log "/!\ ${*} should be running but it's not"
    #touch /useremain/rinkhals/.disable-rinkhals
    exit 1
}
function check_by_port() {
    XPORT=`printf "%04X" ${*}`
    INODE=`cat /proc/net/tcp | grep 00000000:$XPORT | awk '/.*:.*:.*/{print $10;}'` # Port 2222
    if [[ "$INODE" != "" ]]; then
        return
    fi

    log "/!\ Port ${*} should be listening but it's not"
    exit 1
}


################
log "> Starting Moonraker..."

mkdir -p /userdata/app/gk/printer_data
umount /userdata/app/gk/printer_data 2> /dev/null
mount --bind /home/rinkhals/printer_data /userdata/app/gk/printer_data

kill_by_name moonraker.py
HOME=/userdata/app/gk /usr/bin/python /usr/share/moonraker/moonraker/moonraker.py >> /moonraker.log &
check_by_name moonraker.py

kill_by_name moonraker-proxy.py
/usr/bin/python /usr/share/scripts/moonraker-proxy.py 1>> /moonraker.log 2>> /moonraker.log &
check_by_name moonraker-proxy.py

#/usr/bin/python -m /usr/share/octoapp/moonraker_octoapp "ewogICAgJ0tsaXBwZXJDb25maWdGb2xkZXInOiAnL3VzZXJlbWFpbi9yaW5raGFscy9xdWljay1kZXBsb3kvaG9tZS9yaW5raGFscy9wcmludGVyX2RhdGEvY29uZmlnJywKICAgICdNb29ucmFrZXJDb25maWdGaWxlJzogJy91c2VyZW1haW4vcmlua2hhbHMvcXVpY2stZGVwbG95L2hvbWUvcmlua2hhbHMvcHJpbnRlcl9kYXRhL2NvbmZpZy9tb29ucmFrZXIuY29uZicsCiAgICAnS2xpcHBlckxvZ0ZvbGRlcic6ICcvdXNlcmVtYWluL3JpbmtoYWxzL3F1aWNrLWRlcGxveS9ob21lL3JpbmtoYWxzL3ByaW50ZXJfZGF0YS9sb2dzJywKICAgICdMb2NhbEZpbGVTdG9yYWdlUGF0aCc6ICcvdXNlcmVtYWluL3JpbmtoYWxzL3F1aWNrLWRlcGxveS9ob21lL3JpbmtoYWxzL29jdG9hcHAnLAogICAgJ0lzT2JzZXJ2ZXInIDogZmFsc2UKfQ=="

# {
#     'KlipperConfigFolder': '/useremain/rinkhals/quick-deploy/home/rinkhals/printer_data/config',
#     'MoonrakerConfigFile': '/useremain/rinkhals/quick-deploy/home/rinkhals/printer_data/config/moonraker.conf',
#     'KlipperLogFolder': '/useremain/rinkhals/quick-deploy/home/rinkhals/printer_data/logs',
#     'LocalFileStoragePath': '/useremain/rinkhals/quick-deploy/home/rinkhals/octoapp',
#     'IsObserver' : false
# }


################
log "> Starting nginx..."

kill_by_name nginx
mkdir -p /var/log/nginx
mkdir -p /var/cache/nginx
/usr/sbin/nginx &
sleep 1
check_by_name nginx


################
log "> Starting mjpg-streamer..."

if [ ! -e /dev/video10 ]; then
    log Webcam /dev/video10 not found. mjpg-streamer will not start
    exit 1
fi

kill_by_name gkcam
kill_by_name mjpg_streamer

sleep 2

LD_LIBRARY_PATH=/usr/lib/mjpg-streamer:$LD_LIBRARY_PATH \
    /usr/bin/mjpg_streamer -i "input_uvc.so -d /dev/video10 -n -r 1280x720" -o "output_http.so -w /usr/share/mjpg-streamer/www" \
    > mjpg_streamer.log 2>&1 &

check_by_name mjpg_streamer


################
# log "> Checking everything..."

# check_by_name moonraker.py
# check_by_name moonraker-proxy.py
# check_by_name nginx
# check_by_name mjpg_streamer

# check_by_port 7125
# check_by_port 7126
# check_by_port 80
# check_by_port 4408
# check_by_port 4409
# check_by_port 8080
