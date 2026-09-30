#!/bin/sh

stop_services() {
    stopping=1
    for service_pid in $service_pids; do
        kill -TERM "$service_pid" 2>/dev/null || true
    done
}

start_service() {
    service_name=$1
    shift

    (
        stopping=0
        child_pid=
        trap 'stopping=1; if [ -n "$child_pid" ]; then kill -TERM "$child_pid" 2>/dev/null || true; fi' TERM INT

        while [ "$stopping" -eq 0 ]; do
            "$@" &
            child_pid=$!
            wait "$child_pid"
            exit_code=$?
            child_pid=

            if [ "$stopping" -eq 0 ]; then
                printf '%s exited with status %s; restarting\n' "$service_name" "$exit_code"
                sleep 1
            fi
        done
    ) &

    service_pids="$service_pids $!"
    service_count=$((service_count + 1))
}

if [ "${1:-}" = 'app' ]; then
    service_count=0
    service_pids=

    if [ "${ENABLE_SERVER:-0}" = "1" ]; then
        start_service server su-exec ladang php -d variables_order=EGPCS /home/ladang/app/artisan octane:start --host=0.0.0.0 --workers="${OCTANE_WORKER}" --task-workers="${OCTANE_TASK_WORKER}" --max-requests="${OCTANE_MAX_REQUESTS}"
    fi

    if [ "${ENABLE_WORKER:-0}" = "1" ]; then
        start_service worker su-exec ladang php /home/ladang/app/artisan horizon
        start_service crond /usr/sbin/crond -f
    fi

    if [ "${ENABLE_AUTORELOAD:-0}" = "1" ]; then
        start_service autoreload su-exec ladang /usr/local/bin/autoreload.sh
    fi

    if [ "$service_count" -eq 0 ]; then
        exit 0
    fi

    stopping=0
    trap 'stop_services' TERM INT
    while [ "$stopping" -eq 0 ]; do
        wait
    done
    wait
    exit 0
fi

exec "$@"
