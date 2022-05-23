#!/bin/sh

mkdir -p /var/nginx/client_body_temp
chown ladang:ladang /var/nginx/client_body_temp

if [ "$1" = 'app' ]; then
    exec supervisord --nodaemon --configuration="/etc/supervisord.conf" --loglevel=info
fi
