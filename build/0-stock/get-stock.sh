#!/bin/sh

# Without Rinkhals running, run from Docker:
#   docker run --rm -it -e KOBRA_IP=x.x.x.x -v .\build:/build -v .\files:/files --entrypoint=/bin/sh rclone/rclone:1.68.2 /build/0-stock/get-stock.sh


if [ "$KOBRA_IP" == "x.x.x.x" ] || [ "$KOBRA_IP" == "" ]; then
    echo "Please specify your Kobra 3 IP using KOBRA_IP environment variable"
    exit 1
fi


export RCLONE_CONFIG_KOBRA_TYPE=sftp
export RCLONE_CONFIG_KOBRA_HOST=$KOBRA_IP
export RCLONE_CONFIG_KOBRA_PORT=${KOBRA_PORT:-2222}
export RCLONE_CONFIG_KOBRA_USER=root
export RCLONE_CONFIG_KOBRA_PASS=$(rclone obscure "rockchip")


mkdir -p /files/0-stock/lib/udev
mkdir -p /files/0-stock/usr/bin
mkdir -p /files/0-stock/usr/lib
mkdir -p /files/0-stock/usr/share
mkdir -p /files/0-stock/etc/profile.d

rclone -v sync Kobra:/lib/udev /files/0-stock/lib/udev
rclone -v sync --sftp-skip-links Kobra:/usr/bin /files/0-stock/usr/bin
rclone -v sync --sftp-skip-links Kobra:/usr/lib /files/0-stock/usr/lib
rclone -v sync --sftp-skip-links Kobra:/usr/share /files/0-stock/usr/share
rclone -v sync Kobra:/etc/profile.d /files/0-stock/etc/profile.d
