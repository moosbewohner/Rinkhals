#!/bin/sh

function beep() {
    echo 1 > /sys/class/pwm/pwmchip0/pwm0/enable
    usleep $((${*}*1000))
    echo 0 > /sys/class/pwm/pwmchip0/pwm0/enable
}

UPDATE_PATH="/useremain/update_swu"
TMP_TOOL_PATH="/tmp/tools-ssh"

# Create a temp directory
mkdir -p $TMP_TOOL_PATH
rm -rf $TMP_TOOL_PATH/*

# Copy the files
cp -r $UPDATE_PATH/* $TMP_TOOL_PATH/
chmod +x $TMP_TOOL_PATH/sftp-server
chmod +x $TMP_TOOL_PATH/dropbear

# Kill anything on port 2222
INODE=`cat /proc/net/tcp | grep 00000000:08AE | awk '/.*:.*:.*/{print $10;}'`
if [[ "$INODE" != "" ]]; then
    PID=`ls -l /proc/*/fd/* 2> /dev/null | grep "socket:\[$INODE\]" | awk -F'/' '{print $3}'`
    kill -9 $PID
    sleep 1
fi

# Run the SSH server
umount -l /usr/libexec 2> /dev/null
mount --bind $TMP_TOOL_PATH /usr/libexec

LD_LIBRARY_PATH=$TMP_TOOL_PATH $TMP_TOOL_PATH/dropbear -F -E -a -p 2222 -P $TMP_TOOL_PATH/dropbear.pid -r $TMP_TOOL_PATH/dropbear_rsa_host_key \
    >> $TMP_TOOL_PATH/dropbear.log 1>&2 &

# Beep to notify completion
beep 500
