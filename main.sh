#!/bin/sh

set -e

cd /usr/src/phabricator

if [[ "$PHABRICATOR_DOCKER_DONT_SET_MYSQL" != 1 ]]; then
	bin/config set mysql.host $MYSQL_PORT_3306_TCP_ADDR
	bin/config set mysql.port $MYSQL_PORT_3306_TCP_PORT
fi

mkdir -p /var/lib/phabricator/repo
chown -R phabricator-daemon /var/lib/phabricator/repo

mkdir -p /var/lib/phabricator/storage
chown -R www-data /var/lib/phabricator/storage

mkdir -p /var/tmp/phd/log
mkdir -p /var/tmp/phd/pid
chown -R phabricator-daemon /var/tmp/phd

sleep 5

mysqluser=$(bin/config get mysql.user | jq ".config[0].value" | sed 's/^"//g; s/"$//g')
mysqlpass=$(bin/config get mysql.pass | jq ".config[0].value" | sed 's/^"//g; s/"$//g')
mysqlhost=$(bin/config get mysql.host | jq ".config[0].value" | sed 's/^"//g; s/"$//g')
mysqlport=$(bin/config get mysql.port | jq ".config[0].value" | sed 's/^"//g; s/"$//g')
sh /mysql-wait.sh $mysqluser $mysqlpass $mysqlhost $mysqlport
echo y | bin/storage upgrade --force

/usr/bin/supervisord -c /etc/supervisor.conf
