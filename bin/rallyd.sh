#!/bin/bash

name="rallyd-isolated"
pid_file="/var/run/$name.pid"

get_backends() {
    backends=""
    for addr in $(fuel nodes | grep "controller" | grep -Eo "([0-9]{1,3}[\.]){3}[0-9]{1,3}" 2>/dev/null)
    do
        backends="$backends $addr:8888"
    done
    echo ${backends}
}

enable_admin_api() {
    apache_proxy_conf="/etc/apache2/sites-enabled/25-apache_api_proxy.conf"
    enable_command="sed -i '/AllowCONNECT/ s/$/ 35357/' ${apache_proxy_conf}; service apache2 restart"
    enable_with_check="if \$(grep AllowCONNECT ${apache_proxy_conf} | grep -qv 35357); then ${enable_command}; fi"

    for addr in $(fuel nodes | grep "controller" | grep -Eo "([0-9]{1,3}[\.]){3}[0-9]{1,3}" 2>/dev/null)
    do
        ssh $addr "${enable_with_check}"
    done
}

get_pid() {
    cat "$pid_file"
}

is_running() {
    [ -f "$pid_file" ] && docker ps | grep `get_pid` > /dev/null 2>&1
}

case "$1" in
    start)
    if is_running; then
        echo "Already started"
    else
        echo "Starting $name"
        enable_admin_api
        pid=$(docker run -d -e BACKEND_IPS="$(get_backends)" -p 0.0.0.0:10000:8000 rallyd-isolated)
        echo ${pid:0:12} > "$pid_file"
        docker exec `get_pid` /bin/bash -c "mkdir /root/.ssh"
        docker exec -i `get_pid` /bin/bash -c "cat > /root/.ssh/id_rsa" < /root/.ssh/id_rsa
        docker exec `get_pid` /bin/bash -c "chmod go-rwx /root/.ssh/id_rsa"
    fi
    ;;
    stop)
    if is_running; then
        echo -n "Stopping $name.."
        docker stop `get_pid`
        for i in {1..10}
        do
            if ! is_running; then
                break
            fi

            echo -n "."
            sleep 1
        done
        echo

        if is_running; then
            echo "Not stopped; may still be shutting down or shutdown may have failed"
            exit 1
        else
            echo "Stopped"
            if [ -f "$pid_file" ]; then
                rm "$pid_file"
            fi
        fi
    else
        echo "Not running"
    fi
    ;;
    restart)
    $0 stop
    if is_running; then
        echo "Unable to stop, will not attempt to start"
        exit 1
    fi
    $0 start
    ;;
    status)
    if is_running; then
        echo "Running"
    else
        echo "Stopped"
        exit 1
    fi
    ;;
    *)
    echo "Usage: $0 {start|stop|restart|status}"
    exit 1
    ;;
esac

exit 0