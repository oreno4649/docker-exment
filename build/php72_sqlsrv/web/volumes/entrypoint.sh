#!/bin/bash

FILE=/tmp/nginx/initialized
if [ ! -e $FILE ]; then
    sed -i -e "s/%EXMENT_DOCKER_PHP_HOST_NAME%/${EXMENT_DOCKER_PHP_HOST_NAME:-php}/" /tmp/nginx/nginx.conf
    cp -f /tmp/nginx/nginx.conf /etc/nginx/conf.d/default.conf
    touch /tmp/nginx/initialized
fi

exec "$@"