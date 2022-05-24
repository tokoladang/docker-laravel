#!/bin/sh

if [ "$1" = 'app' ]; then

    # Reset Supervisor Configuration
    exec reset-supervisor.sh

    if [[ "${ENABLE_SERVER}" = "1" ]] ; then
        mv /etc/supervisor.d/swoole.disabled /etc/supervisor.d/swoole.ini
    fi

    if [[ "${ENABLE_WORKER}" = "1" ]] ; then
        mv /etc/supervisor.d/crond.disabled /etc/supervisor.d/crond.ini
        mv /etc/supervisor.d/worker.disabled /etc/supervisor.d/worker.ini
    fi

    if [[ "${ENABLE_AUTORELOAD}" = "1" ]] ; then
        mv /etc/supervisor.d/autoreload.disabled /etc/supervisor.d/autoreload.ini
    fi

    exec supervisord -n -c "/etc/supervisord.conf"
fi
