#!/bin/sh

# Run from Docker:
#   docker run --privileged --rm tonistiigi/binfmt --install all
#   docker run --rm -it -v .\build:/build -v .\files:/files ghcr.io/jbatonnet/rinkjals/python /build/3-python/copy-output.sh

mkdir -p /files/3-python/usr/lib/python3.12/site-packages
rm -rf /files/3-python/usr/lib/python3.12/site-packages/*

find /usr/local/lib/python3.12/site-packages -name '*.pyc' -type f -delete
cp -r /usr/local/lib/python3.12/site-packages/* /files/3-python/usr/lib/python3.12/site-packages
