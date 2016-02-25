#!/bin/sh

invoke-listeners() {
	for f in $(ls /phabricator-docker/$1); do
		/phabricator-docker/$1/$f
	done
}

set-in-config() {
	bin/config set $1 $2
}

get-from-config() {
	bin/config get $1 | jq ".config[0].value" | sed 's/^"//g; s/"$//g'
}


cd /usr/src/phabricator

# setup
invoke-listeners on-pre-setup

set-in-config mysql.host $MYSQL_PORT_3306_TCP_ADDR
set-in-config mysql.port $MYSQL_PORT_3306_TCP_PORT

mkdir -p /var/lib/phabricator/repo
chown -R phabricator-daemon /var/lib/phabricator/repo

mkdir -p /var/lib/phabricator/storage
chown -R www-data /var/lib/phabricator/storage

mkdir -p /var/tmp/phd/{log,pid}
chown -R phabricator-daemon /var/tmp/phd

invoke-listeners on-post-setup

# fetch mysql creditinals
export PHABRICATOR_MYSQL_USER=$(get-from-config mysql.user)
export PHABRICATOR_MYSQL_PASS=$(get-from-config mysql.pass)
export PHABRICATOR_MYSQL_HOST=$(get-from-config mysql.host)
export PHABRICATOR_MYSQL_PORT=$(get-from-config mysql.port)

sh /mysql-wait.sh $PHABRICATOR_MYSQL_USER $PHABRICATOR_MYSQL_PASS $PHABRICATOR_MYSQL_HOST $PHABRICATOR_MYSQL_PORT

invoke-listeners on-mysql

# upgrade storage
echo y | bin/storage upgrade --force

# run
invoke-listeners on-pre-start

/usr/bin/supervisord -c /etc/supervisor.conf

invoke-listeners on-stop
