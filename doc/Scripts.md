# Scripts


```
for i in `ls /proc/*/cmdline`; do
    PID=`echo $i | awk -F'/' '{print $3}'`
    CMDLINE=`cat $i` 2>/dev/null

    if [[ "$CMDLINE" != "" ]]; then
        echo $PID: $CMDLINE
    fi
done
```


```
for protocol in tcp udp ; 
do 
    #echo "protocol $protocol" ; 
    for ipportinode in `cat /proc/net/${protocol} | awk '/.*:.*:.*/{print $2"|"$3"|"$10 ;}'` ; 
    do 
        #echo "#ipportinode=$ipportinode"
        inode=`echo "$ipportinode" | cut -d"|" -f3` ;
        if [ "#$inode" = "#" ] ; then continue ; fi 
        lspid=`ls -l /proc/*/fd/* 2>/dev/null | grep "socket:\[$inode\]" 2>/dev/null` ; 
        pid=`echo "lspid=$lspid" | awk 'BEGIN{FS="/"} /socket/{print $3}'` ;
        if [ "#$pid" = "#" ] ; then continue ; fi
        exefile=`ls -l /proc/$pid/exe | awk 'BEGIN{FS=" -> "}/->/{print $2;}'`
        #echo "$protocol|$pid|$ipportinode" 
        echo "$protocol|$pid|$ipportinode|$exefile" | awk '
            BEGIN{FS="|"}
            function iphex2dec(ipport){ 
                ret=sprintf("%d.%d.%d.%d:    %d","0x"substr(ipport,1,2),"0x"substr(ipport,3,2),
                "0x"substr(ipport,5,2),"0x"substr(ipport,7,2),"0x"substr(ipport,10,4)) ;
                if( ret == "0.0.0.0:0" ) #compatibility others awk versions 
                {
                    ret=        strtonum("0x"substr(ipport,1,2)) ;
                    ret=ret "." strtonum("0x"substr(ipport,3,2)) ;
                    ret=ret "." strtonum("0x"substr(ipport,5,2)) ;
                    ret=ret "." strtonum("0x"substr(ipport,7,2)) ;
                    ret=ret ":" strtonum("0x"substr(ipport,10)) ;
                }
                return ret ;
            }
            { 
            print $1" pid:"$2" local="iphex2dec($3)" remote="iphex2dec($4)" inode:"$5" exe=" $6 ;  
            }
            ' ; 
        #ls -l /proc/$pid/exe ; 
    done ; 
done
```


```
PORT=2222
XPORT=`printf "%04X" $PORT`
INODE=`cat /proc/net/tcp | grep 00000000:$XPORT | awk '/.*:.*:.*/{print $10;}'`
PID=`ls -l /proc/*/fd/* 2> /dev/null | grep "socket:\[$INODE\]" | awk -F'/' '{print $3}'`
CMDLINE=`cat /proc/$PID/cmdline`
echo [$PID]: $CMDLINE
```

```
echo
echo "!! Starting debug shell..."
/bin/ash -i
exit 0
```

```
date -s '2009-02-13 11:31:30'
```

```
LD_LIBRARY_PATH=/useremain/rinkhals/.current/lib:/useremain/rinkhals/.current/usr/lib /useremain/rinkha
ls/.current/lib/ld-linux-armhf.so.3 /useremain/rinkhals/.current/usr/bin/strace /useremain/rinkhals/.current/lib/ld-linu
x-armhf.so.3 /useremain/rinkhals/.current/usr/bin/python

LD_LIBRARY_PATH=/useremain/rinkhals/.current/lib:/useremain/rinkhals/.current/usr/lib /useremain/rinkhals/.current/lib/ld-linux-armhf.so.3 /useremain/rinkhals/.current/usr/bin/python

HOME=/useremain/rinkhals/.current/home/rinkhals LD_LIBRARY_PATH=/useremain/rinkhals/.current/lib:/useremain/rinkhals/.current/usr/lib /useremain/rinkhals/.current/lib/ld-linux-armhf.so.3 /useremain/rinkhals/.current/usr/bin/python /useremain/rinkhals/.current/usr/share/moonraker/moonraker/moonraker.py

OctoApp:
LD_LIBRARY_PATH=/useremain/rinkhals/.current/lib:/useremain/rinkhals/.current/usr/lib /useremain/rinkhals/.current/lib/ld-linux-armhf.so.3 /useremain/rinkhals/.current/usr/bin/python


```