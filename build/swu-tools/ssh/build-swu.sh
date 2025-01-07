#!/bin/sh

# From a Windows machine:
#   docker run --rm -it -v .\build:/build -v .\files:/files ghcr.io/jbatonnet/rinkhals/build /build/swu-tools/ssh/build-swu.sh

set -e


# Prepare update
mkdir -p /tmp/update_swu
rm -rf /tmp/update_swu/*

cp /build/swu-tools/ssh/update.sh /tmp/update_swu/update.sh
cp /files/4-rinkhals/usr/local/etc/dropbear/dropbear_rsa_host_key /tmp/update_swu/dropbear_rsa_host_key
cp /files/1-buildroot/usr/lib/libcrypto.so.1.1 /tmp/update_swu/libcrypto.so.1.1
cp /files/1-buildroot/usr/lib/libssl.so.1.1 /tmp/update_swu/libssl.so.1.1
cp /files/1-buildroot/lib/libatomic.so.1 /tmp/update_swu/libatomic.so.1
cp /files/1-buildroot/lib/libc.so.0 /tmp/update_swu/libc.so.0
cp /files/1-buildroot/lib/ld-uClibc.so.0 /tmp/update_swu/ld-uClibc

# Patch dropbear to run sftp-server locally
cat /files/1-buildroot/usr/sbin/dropbear |
    sed "s/\/lib\/ld-uClibc.so.0/\/tmp\/ssh\/\/ld-uClibc/g" |
    sed "s/\/usr\/libexec\/sftp-server/\/tmp\/ssh\/sftp-server    /g" \
    > /tmp/update_swu/dropbear

cat /files/1-buildroot/usr/libexec/sftp-server |
    sed "s/\/lib\/ld-uClibc.so.0/\/tmp\/ssh\/\/ld-uClibc/g" \
    > /tmp/update_swu/sftp-server

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
