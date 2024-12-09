#!/bin/sh

if [ ! -f /useremain/rinkhals/.version ]; then
    echo Rinkhals is installed but no version is selected to start
    exit 1
fi

if [ -f /mnt/udisk/.disable-rinkhals ] || [ -f /useremain/rinkhals/.disable-rinkhals ]; then
    echo Rinkhals statup was stopped with the .disable-rinkhals file
    exit 1
fi

RINKHALS_VERSION=`cat /useremain/rinkhals/.version`
echo Rinkhals version $RINKHALS_VERSION selected

if [ ! -d /useremain/rinkhals/$RINKHALS_VERSION ]; then
    echo Rinkhals version $RINKHALS_VERSION does not exist
    exit 1
fi

rm -rf /useremain/rinkhals/.current 2> /dev/null
ln -s /useremain/rinkhals/$RINKHALS_VERSION /useremain/rinkhals/.current

cd /useremain/rinkhals/$RINKHALS_VERSION

chmod +x ./start.sh
./start.sh
