#!/usr/bin/env bash

if [ -z "$APP" ] ; then
	set -e
	APP="$( cd $(dirname "$0")/../../../.. ; pwd )"
	echo "$0: Working in: $APP"  >&2
	[ -d "$APP/source" ] || ( echo "expecting 'source' directory." >&2 && exit 1 )
fi

. "$APP/source/myx/myx.distro-prepare/sh-scripts/list-all-source-repositories.sh"
SOURCE_REPOS="`ListAllSourceRepositories`"


DISTRO_PATH="$APP/distro"

SyncRepositoryDistroFromSource(){
	local REPO="$1"
	echo "Will check for changes, repository: $REPO"
}

RebuildDistroFromSource(){
	echo "Will check for changes"
	for REPO in $SOURCE_REPOS ; do
		SyncRepositoryDistroFromSource "$REPO"
	done
}

case "$0" in
	*/sh-scripts/rebuild-distro-from-source.sh) 
		RebuildDistroFromSource "$@"
	;;
esac