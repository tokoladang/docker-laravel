#!/bin/sh

if [ "$1" = 'app' ]; then
    if [[ "${WORKER}" = "true" ]] || [[ "${WORKER}" = "1" ]] ; then
        exec supervisord --nodaemon --configuration="/etc/workers/supervisord.conf" --loglevel=info
    else
        exec supervisord --nodaemon --configuration="/etc/webs/supervisord.conf" --loglevel=info
    fi
fi
