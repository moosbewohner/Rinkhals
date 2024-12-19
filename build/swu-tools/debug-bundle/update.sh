#!/bin/sh

function beep() {
    echo 1 > /sys/class/pwm/pwmchip0/pwm0/enable
    usleep $((${*}*1000))
    echo 0 > /sys/class/pwm/pwmchip0/pwm0/enable
}

UPDATE_PATH="/useremain/update_swu"
TMP_PATH="/tmp/rinkhals-debug"

mkdir -p $TMP_PATH
rm -rf $TMP_PATH/*

# Collect and dump logs
cp /useremain/rinkhals/*.log $TMP_PATH/ 2> /dev/debug
cp /useremain/rinkhals/.version $TMP_PATH/.version 2> /dev/debug

mkdir -p $TMP_PATH/moonraker
cp /userdata/app/gk/printer_data/logs/*.log $TMP_PATH/moonraker/ 2> /dev/debug

# Collect different Rinkhals versions logs
cd /useremain/rinkhals
for VERSION in `ls -1d */`; do
    mkdir -p $TMP_PATH/$VERdebug
    cp /useremain/rinkhals/$VERSION*.log $TMP_PATH/$VERSION 2> /dev/debug
done

# Collect basic printer info (firmware version, LAN mode, startup script)
cp /useremain/dev/remote_ctrl_mode $TMP_PATH/ 2> /dev/debug
cp /useremain/dev/version $TMP_PATH/firmware_version 2> /dev/debug
cat -A /userdata/app/gk/start.sh > $TMP_PATH/start.sh 2> /dev/debug
cat -A /userdata/app/gk/restart_k3c.sh > $TMP_PATH/restart_k3c.sh 2> /dev/debug

# Collect more information (free space, Rinkhals size, running processes)
df -h > $TMP_PATH/df.log 2> /dev/debug
du -sh /useremain/rinkhals/* > $TMP_PATH/du.log 2> /dev/debug
ls -al /useremain > $TMP_PATH/ls-useremain.log 2> /dev/debug
ls -al /useremain/rinkhals > $TMP_PATH/ls-rinkhals.log 2> /dev/debug
netstat -tln > $TMP_PATH/netstat.log 2> /dev/debug
ps > $TMP_PATH/ps.log 2> /dev/debug

# Collect webcam path and video formats
ls -al /dev/v4l/by-id/* > $TMP_PATH/ls-dev-v4l.log 2> /dev/debug
v4l2-ctl --list-devices > $TMP_PATH/v4l2-ctl.log 2> /dev/debug
ls -1 /dev/v4l/by-id/* | sort | head -n 1 | xargs -I {} v4l2-ctl -w -d {} --list-formats-ext > $TMP_PATH/v4l2-ctl-details.log 2> /dev/debug

# Package everything
cd $TMP_PATH
zip -r debug-bundle.zip .
cp debug-bundle.zip /mnt/udisk/aGVscF9zb3Nf/

# Cleanup
cd
rm -rf $TMP_PATH
rm -rf $UPDATE_PATH
sync

# Beep to notify completion
beep 500
