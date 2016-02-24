#!/bin/sh

VCSUSER="phabricator-vcs"
ROOT="/usr/src/phabricator"

if [ "$1" != "$VCSUSER" ];
then
  exit 1
fi

exec "$ROOT/bin/ssh-auth" $@
