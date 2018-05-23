#!/usr/bin/env bash

if [ -z "$APP" ] ; then
	set -e
	APP="$( cd $(dirname "$0")/../../../.. ; pwd )"
	echo "$0: Working in: $APP"  >&2
	[ -d "$APP/source" ] || ( echo "expecting 'source' directory." >&2 && exit 1 )
fi

. "$APP/source/myx/myx.distro-prepare/sh-scripts/list-all-source-repositories.sh"
. "$APP/source/myx/myx.distro-prepare/sh-scripts/list-source-repository-packages.sh"

ListAllSourcePackages(){
	for REPO in $( ListAllSourceRepositories ) ; do
		ListSourceRepositoryPackages "$REPO"
	done	
}

case "$0" in
	*/sh-scripts/list-all-source-packages.sh) 
		ListAllSourcePackages
	;;
esac