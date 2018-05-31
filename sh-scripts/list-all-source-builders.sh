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
if [ "`type -t ListSourceProjectBuilders`" != "function" ] ; then
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-source-project-builders.sh"
fi

ListAllSourceBuildersRaw(){
	for PKG in $( ListAllSourceProjects ) ; do
		ListSourceProjectBuilders "$PKG"
	done
}

ListAllSourceBuilders(){
	ListAllSourceBuildersRaw |\
				    awk -v FS=/ -v OFS=/ '{ print $NF,$0 }' |\
				    sort -n -t / |\
				    cut -f2- -d/
}

case "$0" in
	*/sh-scripts/list-all-source-builders.sh) 
		ListAllSourceBuilders
	;;
esac