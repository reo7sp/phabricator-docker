#!/bin/sh

set -e

cd /usr/src/phabricator
bin/config set mysql.host "$MYSQL_PORT_3306_TCP_ADDR:$MYSQL_PORT_3306_TCP_PORT"
bin/storage upgrade --force

/usr/bin/supervisord -c /etc/supervisor.conf
