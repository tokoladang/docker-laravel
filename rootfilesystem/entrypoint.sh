#!/bin/sh

if [ "$1" = 'app' ]; then
    if [[ "${WORKER}" = "true" ]] || [[ "${WORKER}" = "1" ]] ; then
        exec supervisord -n -c "/etc/workers/supervisord.conf"
    else
        exec supervisord -n -c "/etc/webs/supervisord.conf"
    fi
fi
