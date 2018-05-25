#!/usr/bin/env bash

if [ -z "$MMDAPP" ] ; then
	set -e
	export MMDAPP="$( cd $(dirname "$0")/../../../.. ; pwd )"
	echo "$0: Working in: $MMDAPP"  >&2
	[ -d "$MMDAPP/source" ] || ( echo "expecting 'source' directory." >&2 && exit 1 )
fi

. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-all-source-repositories.sh"
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-source-repository-packages.sh"

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