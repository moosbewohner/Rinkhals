#!/bin/sh

make

rm -rf /output/*
cp -rL /buildroot/output/target/* /output/

rm -rf /output/dev
rm -rf /output/lib32
rm -rf /output/media
rm -rf /output/mnt
rm -rf /output/opt
rm -rf /output/proc
rm -rf /output/root
rm -rf /output/run
rm -rf /output/sys
rm -rf /output/tmp
rm -rf /output/usr/lib32
rm -rf /output/var
rm /output/THIS_IS_NOT_YOUR_ROOT_FILESYSTEM
rm /output/linuxrc

rm -rf /output/usr/lib/python3.12/site-packages/*
find /output/usr/lib/python3.12 -name '*.pyc' -type f -delete
