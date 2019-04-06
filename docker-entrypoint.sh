#!/bin/bash
set -e

function prepare() {
    chmod 777 -R tmp
}

function gen_config() {
    PATH_CONFIG_TEMPLATE=/app/include/config-sample.inc.php
    PATH_CONFIG=/app/include/config.inc.php

    DB_HOST=${DB_HOST:=mariadb}
    DB_PORT=${DB_PORT:=3306}
    DB_USER=${DB_USER:=dev}
    DB_PASSWORD=${DB_PASSWORD:=dev123}
    DB_NAME=${DB_NAME:=arionum}

    # Create config from template
    cp $PATH_CONFIG_TEMPLATE $PATH_CONFIG

    # Update config
    DB_CONNECT="db_connect'] = 'mysql:host=${DB_HOST};port=${DB_PORT};dbname=${DB_NAME}';"
    sed -i -e "s/db_connect.*$/$DB_CONNECT/g" $PATH_CONFIG
    sed -i -e s/ENTER-DB-NAME/$DB_NAME/g $PATH_CONFIG
    sed -i -e s/ENTER-DB-USER/$DB_USER/g $PATH_CONFIG
    sed -i -e s/ENTER-DB-PASS/$DB_PASSWORD/g $PATH_CONFIG

    # Update Masternode config
    MASTERNODE_ENABLE="masternode'] = true;"
    sed -i -e "s/masternode'.*$/$MASTERNODE_ENABLE/g" $PATH_CONFIG

    MASTERNODE_PUBLIC_KEY_CONFIG="masternode_public_key'] = '${MASTERNODE_PUBLIC_KEY}';"
    sed -i -e "s/masternode_public_key'.*$/$MASTERNODE_PUBLIC_KEY_CONFIG/g" $PATH_CONFIG
}

# prepare for config default
prepare
gen_config

if [ "$1" = 'php-fpm' ]; then
    ####### Handle SIGTERM #######
    function _term() {
        printf "%s\n" "Caught terminate signal!"

        kill -SIGTERM $child 2>/dev/null
        exit 0
    }

    trap _term SIGHUP SIGINT SIGTERM SIGQUIT

    ####### Start application #######
    php-fpm &

    child=$!
    wait "$child"
fi

exec "$@"
