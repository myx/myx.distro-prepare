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
if [ "`type -t ListSourceProjectActions`" != "function" ] ; then
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-source-project-actions.sh"
fi


ListAllSourceActions(){
	for PKG in $( ListAllSourceProjects ) ; do
		ListSourceProjectActions "$PKG"
	done	
}

case "$0" in
	*/sh-scripts/list-all-source-actions.sh) 
		ListAllSourceActions
	;;
esac