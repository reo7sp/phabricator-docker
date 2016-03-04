#!/bin/bash

export PHABRICATOR_HOME=/usr/src/phabricator

_invoke_listeners() {
	for f in $(ls /phabricator-docker/$1); do
		/phabricator-docker/$1/$f
	done
}

phabricator_set_in_config() {
	$PHABRICATOR_HOME/bin/config set $1 $2
}
export -f phabricator_set_in_config

phabricator_get_from_config() {
	$PHABRICATOR_HOME/bin/config get $1 | jq ".config[0].value" | sed 's/^"//g; s/"$//g'
}
export -f phabricator_get_from_config


cd $PHABRICATOR_HOME

# setup
_invoke_listeners on_pre_setup

phabricator_set_in_config mysql.host $MYSQL_PORT_3306_TCP_ADDR
phabricator_set_in_config mysql.port $MYSQL_PORT_3306_TCP_PORT

mkdir -p /var/lib/phabricator/repo
chown -R phabricator-daemon /var/lib/phabricator/repo

mkdir -p /var/lib/phabricator/storage
chown -R www-data /var/lib/phabricator/storage

mkdir -p /var/tmp/phd/{log,pid}
chown -R phabricator-daemon /var/tmp/phd

_invoke_listeners on_post_setup

# fetch mysql creditinals
export PHABRICATOR_MYSQL_USER=$(phabricator_get_from_config mysql.user)
export PHABRICATOR_MYSQL_PASS=$(phabricator_get_from_config mysql.pass)
export PHABRICATOR_MYSQL_HOST=$(phabricator_get_from_config mysql.host)
export PHABRICATOR_MYSQL_PORT=$(phabricator_get_from_config mysql.port)

sh /mysql-wait.sh $PHABRICATOR_MYSQL_USER $PHABRICATOR_MYSQL_PASS $PHABRICATOR_MYSQL_HOST $PHABRICATOR_MYSQL_PORT
if [[ $? != 0 ]]; then
	echo "Can't connect to mysql"
	exit 1
fi

_invoke_listeners on_mysql

# upgrade storage
echo y | bin/storage upgrade --force

# run
_invoke_listeners on_pre_start

/usr/bin/supervisord -c /etc/supervisor.conf

_invoke_listeners on_stop
