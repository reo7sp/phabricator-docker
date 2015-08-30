#!/bin/sh

if [ -z "$1" -a -z "$2" -a -z "$3" ]
then
	echo >&2 "Usage: /mysql-wait.sh USER PASS HOST PORT"
	exit 1
fi

echo "mysql is starting..."
i=60
while [ $i -ne 0 ]
do
	echo "SELECT 1" | mysql -u $1 -p $2 -h $3 --port $4
	if [ $? -eq 0 ]
	then
		exit 0
	fi
	sleep 1
	i=$((i-1))
done
if [ "$i" -eq 0 ]
then
	echo >&2 "mysql failed to start."
	exit 1
else
	echo "Done"
fi
