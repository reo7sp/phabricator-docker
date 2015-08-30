#!/bin/sh

cd /usr/src/phabricator

bin/config set mysql.host $MYSQL_PORT_3306_TCP_ADDR:$MYSQL_PORT_3306_TCP_PORT
sleep 5
mysqluser=$(bin/config get mysql.user | jq ".config[0].value" | sed 's/^"//g; s/"$//g')
mysqlpass=$(bin/config get mysql.pass | jq ".config[0].value" | sed 's/^"//g; s/"$//g')
sh /mysql-wait.sh $mysqluser $mysqlpass $MYSQL_PORT_3306_TCP_ADDR $MYSQL_PORT_3306_TCP_PORT
bin/storage upgrade --force

/usr/bin/supervisord -c /etc/supervisor.conf
