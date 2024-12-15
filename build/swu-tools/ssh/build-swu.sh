#!/bin/sh

# From a Windows machine:
#   docker run --rm -it -v .\build:/build -v .\files:/files ghcr.io/jbatonnet/rinkjals/build /build/swu-tools/ssh/build-swu.sh

set -e


# Prepare update
mkdir -p /tmp/update_swu
rm -rf /tmp/update_swu/*

mkdir -p /tmp/update_swu/etc/dropbear
mkdir -p /tmp/update_swu/lib
mkdir -p /tmp/update_swu/usr/lib
mkdir -p /tmp/update_swu/usr/libexec
mkdir -p /tmp/update_swu/usr/sbin
mkdir -p /tmp/update_swu/usr/share/scripts

cp /build/swu-tools/ssh/update.sh /tmp/update_swu/update.sh
cp /files/4-rinkhals/etc/dropbear/dropbear_rsa_host_key /tmp/update_swu/etc/dropbear/dropbear_rsa_host_key
cp /files/1-buildroot/lib/ld-linux-armhf.so.3 /tmp/update_swu/lib/ld-linux-armhf.so.3
cp /files/1-buildroot/lib/libc.so.6 /tmp/update_swu/lib/libc.so.6
cp /files/1-buildroot/usr/lib/libcrypt.so.2 /tmp/update_swu/usr/lib/libcrypt.so.2
cp /files/1-buildroot/usr/lib/libcrypto.so.3 /tmp/update_swu/usr/lib/libcrypto.so.3
cp /files/1-buildroot/usr/lib/libssl.so.3 /tmp/update_swu/usr/lib/libssl.so.3
cp /files/1-buildroot/usr/libexec/sftp-server /tmp/update_swu/usr/libexec/sftp-server
cp /files/1-buildroot/usr/sbin/dropbear /tmp/update_swu/usr/sbin/dropbear
cp /build/swu-tools/ssh/sftp-server /tmp/update_swu/usr/share/scripts/sftp-server


# Create the setup.tar.gz
echo "Building update package..."

mkdir -p /build/dist/update_swu
rm -rf /build/dist/update_swu/*

cd /tmp/update_swu
tar -czf /build/dist/update_swu/setup.tar.gz --exclude='setup.tar.gz' .


# Create the update.swu
rm -rf /build/dist/update.swu

cd /build/dist
zip -P U2FsdGVkX19deTfqpXHZnB5GeyQ/dtlbHjkUnwgCi+w= -r update.swu update_swu

echo "Done, your update package is ready: build/dist/update.swu"
