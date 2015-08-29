#!/bin/sh

set -e

/usr/src/phabricator/bin/storage upgrade --force
/usr/bin/supervisord -c /etc/supervisor.conf
