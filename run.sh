#!/bin/sh

mkdir -p /var/nginx/client_body_temp
chown ladang:ladang /var/nginx/client_body_temp
mkdir -p /var/run/php/
chown ladang:ladang /var/run/php/
touch /var/log/php-fpm.log
chown ladang:ladang /var/log/php-fpm.log

if [ "$1" = 'app' ]; then
    exec supervisord --nodaemon --configuration="/etc/supervisord.conf" --loglevel=info
fi
