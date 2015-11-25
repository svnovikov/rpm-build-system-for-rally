#!/bin/bash

name="rallyd-isolated"
pid_file="/var/run/$name.pid"

OS_TEST_TIMEOUT=${OS_TEST_TIMEOUT:-1200}

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
        pid=$(docker run -d -e OS_TEST_TIMEOUT=${OS_TEST_TIMEOUT} -p 0.0.0.0:10000:8000 rallyd-isolated rallyd)
        echo ${pid:0:12} > "$pid_file"
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