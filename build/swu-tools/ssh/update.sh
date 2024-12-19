#!/bin/sh

function beep() {
    echo 1 > /sys/class/pwm/pwmchip0/pwm0/enable
    usleep $((${*}*1000))
    echo 0 > /sys/class/pwm/pwmchip0/pwm0/enable
}

UPDATE_PATH="/useremain/update_swu"
TMP_TOOL_PATH="/tmp/swu-ssh"

# Create a temp directory
mkdir -p $TMP_TOOL_PATH
rm -rf $TMP_TOOL_PATH/*

# Copy the files
cp -r $UPDATE_PATH/* $TMP_TOOL_PATH/
chmod +x $TMP_TOOL_PATH/lib/ld-linux-armhf.so.3
chmod +x $TMP_TOOL_PATH/usr/libexec/sftp-server
chmod +x $TMP_TOOL_PATH/usr/sbin/dropbear
chmod +x $TMP_TOOL_PATH/usr/share/scripts/sftp-server

# Run the SSH server
umount /usr/libexec 2> /dev/null
mount --bind $TMP_TOOL_PATH/usr/share/scripts /usr/libexec

LD_LIBRARY_PATH=$TMP_TOOL_PATH/lib:$TMP_TOOL_PATH/usr/lib \
    $TMP_TOOL_PATH/lib/ld-linux-armhf.so.3 $TMP_TOOL_PATH/usr/sbin/dropbear -F -E -a -p 2222 -P $TMP_TOOL_PATH/dropbear.pid -r $TMP_TOOL_PATH/etc/dropbear/dropbear_rsa_host_key \
    1>> $TMP_TOOL_PATH/dropbear.log 2>> $TMP_TOOL_PATH/dropbear.log &

# Cleanup
rm -rf ${update_file_path}
sync

# Beep to notify completion
beep 500
