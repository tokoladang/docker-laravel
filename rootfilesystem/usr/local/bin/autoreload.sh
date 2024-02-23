#!/bin/sh

WATCH_LIST='
    /home/ladang/app/app/ 
    /home/ladang/app/bootstrap/ 
    /home/ladang/app/config/ 
    /home/ladang/app/resources/ 
    /home/ladang/app/routes/
    /home/ladang/app/.env
'

while true ; do
    while read file ; do
        if [[ "php" == "${file##*.}" ]] ; then
            break
        fi
    done < <(inotifywait -r -q --format "%f" -e create,delete,modify,move ${WATCH_LIST})

    exec php /home/ladang/app/artisan octane:reload
    sleep 2
done
