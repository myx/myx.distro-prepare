#!/usr/bin/env bash

if [ -z "$MMDAPP" ] ; then
	set -e
	export MMDAPP="$( cd $(dirname "$0")/../../../.. ; pwd )"
	echo "$0: Working in: $MMDAPP"  >&2
	[ -d "$MMDAPP/source" ] || ( echo "expecting 'source' directory." >&2 && exit 1 )
fi

if [ "`type -t ListAllSourceRepositories`" != "function" ] ; then
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-all-source-repositories.sh"
fi
if [ "`type -t ListSourceRepositoryProjects`" != "function" ] ; then
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-source-repository-projects.sh"
fi

ListAllSourceProjects(){
	for REPO in $( ListAllSourceRepositories ) ; do
		ListSourceRepositoryProjects "$REPO"
	done	
}

case "$0" in
	*/sh-scripts/list-all-source-projects.sh) 
		# list-all-source-projects.sh
		# distro-source.sh --import-from-source --print-projects --print ""
		
		ListAllSourceProjects
	;;
esac