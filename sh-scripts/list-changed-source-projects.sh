#!/usr/bin/env bash

if [ -z "$MMDAPP" ] ; then
	set -e
	export MMDAPP="$( cd $(dirname "$0")/../../../.. ; pwd )"
	echo "$0: Working in: $MMDAPP"  >&2
	[ -d "$MMDAPP/source" ] || ( echo "expecting 'source' directory." >&2 && exit 1 )
fi

if [ "`type -t ListAllSourceProjects`" != "function" ] ; then
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-all-source-projects.sh"
fi

ListChangedSourceProjects(){
	for PKG in $( ListAllSourceProjects ) ; do
		if [ -f "$MMDAPP/cached/changed/$PKG" ] ; then
			echo "$PKG"
		fi
	done	
}

case "$0" in
	*/sh-scripts/list-changed-source-projects.sh) 
		ListChangedSourceProjects
	;;
esac