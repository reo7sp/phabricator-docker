#!/bin/sh

set -e
cd /usr/src/phabricator

bin/config set mysql.host $MYSQL_PORT_3306_TCP_ADDR:$MYSQL_PORT_3306_TCP_PORT

sh /mysql-wait.sh $(bin/config get mysql.user) $(bin/config get mysql.pass) $(bin/config get mysql.host)
bin/storage upgrade --force

/usr/bin/supervisord -c /etc/supervisor.conf
