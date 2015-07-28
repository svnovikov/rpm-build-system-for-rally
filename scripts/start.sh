#!/bin/sh
set -x

export HAOS_SERVER_ENDPOINT=$(ip addr show dev eth0 | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}")':5999'

rally deployment create --fromenv --name=haos

if [ ! -z ${SCENARIO} ]; then
    rally --debug --plugin-path /usr/local/lib/python2.7/site-packages/haos/rally/context,/usr/local/lib/python2.7/site-packages/haos/rally/plugin task start /usr/local/lib/python2.7/site-packages/haos/scenarios/${SCENARIO}
    
    r_code=$?
    $id=$(rally task list | awk '{print $2}' | tail -2)

    if [ $r_code='0' ]; then
        rally task report $id --out output.html
    fi

    cat output.html
fi

exit
