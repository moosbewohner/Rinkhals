msleep() {
    usleep $(($1 * 1000))
}
beep() {
    echo 1 > /sys/class/pwm/pwmchip0/pwm0/enable
    usleep $((${*}*1000))
    echo 0 > /sys/class/pwm/pwmchip0/pwm0/enable
}
log() {
    echo "${*}"

    mkdir -p $RINKHALS_ROOT/logs
    echo "`date`: ${*}" >> $RINKHALS_ROOT/logs/rinkhals.log
}
kill_by_name() {
    PIDS=`ps | grep "$1" | grep -v grep | awk '{print $1}'`

    for PID in `echo "$PIDS"`; do
        CMDLINE=`cat /proc/$PID/cmdline` 2>/dev/null

        log "Killing $PID ($CMDLINE)"
        kill -9 $PID
    done
}
kill_by_port() {
    XPORT=`printf "%04X" ${*}`
    INODE=`cat /proc/net/tcp | grep 00000000:$XPORT | awk '/.*:.*:.*/{print $10;}'`

    if [[ "$INODE" != "" ]]; then
        PID=`ls -l /proc/*/fd/* 2> /dev/null | grep "socket:\[$INODE\]" | awk -F'/' '{print $3}'`
        CMDLINE=`cat /proc/$PID/cmdline`

        log "Killing $PID ($CMDLINE)"
        kill -9 $PID
    fi
}
assert_by_name() {
    PIDS=`ps | grep "$1" | grep -v grep | awk '{print $1}'`

    if [ "$PIDS" == "" ]; then
        log "/!\ ${*} should be running but it's not"
        quit
    fi
}
check_by_port() {
    XPORT=`printf "%04X" ${*}`
    INODE=`cat /proc/net/tcp | grep 00000000:$XPORT | awk '/.*:.*:.*/{print $10;}'` # Port 2222
    if [ "$INODE" != "" ]; then
        return 1
    fi

    return 0
}
wait_for_port() {
    DELAY=250
    TOTAL=0

    while 1; do
        OPEN=`netstat -tln | grep :$1`
        if [ "$OPEN" != "" ]; then
            break
        fi

        if [ $TOTAL > 30 ]; then
            log "/!\ Timeout waiting for port $1 to open"
            quit
        fi

        msleep $DELAY

        TOTAL=$(( $TOTAL + $DELAY ))
        DELAY=$(( $DELAY * 2 ))
    done
}
