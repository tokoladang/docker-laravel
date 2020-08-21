#!/bin/sh

mkdir -p /var/nginx/client_body_temp
chown tokoladang:tokoladang /var/nginx/client_body_temp
mkdir -p /var/run/php/
chown tokoladang:tokoladang /var/run/php/
touch /var/log/php-fpm.log
chown tokoladang:tokoladang /var/log/php-fpm.log

if [ "$1" = 'app' ]; then
    exec supervisord --nodaemon --configuration="/etc/supervisord.conf" --loglevel=info
fi
