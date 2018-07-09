#!/usr/bin/env bash

if [ -z "$MMDAPP" ] ; then
	set -e
	export MMDAPP="$( cd $(dirname "$0")/../../../.. ; pwd )"
	echo "$0: Working in: $MMDAPP"  >&2
	[ -d "$MMDAPP/source" ] || ( echo "expecting 'source' directory." >&2 && exit 1 )
fi

if ! type DistroShellContext >/dev/null 2>&1 ; then
	. "$MMDAPP/source/myx/myx.distro-prepare/sh-lib/DistroShellContext.include"
	DistroShellContext --distro-from-source
fi

Require ListAllProjects
Require ListSourceProjectBuilders

ListAllSourceBuildersRaw(){
	for PKG in $( ListAllProjects ) ; do
		ListSourceProjectBuilders "$PKG" "$@"
	done
}

ListSourceBuilders(){
	ListAllSourceBuildersRaw "$@" |\
				    awk -v FS=/ -v OFS=/ '{ print $NF,$0 }' |\
				    sort -n -t / |\
				    cut -f2- -d/
}

case "$0" in
	*/sh-scripts/ListSourceBuilders.fn.sh) 

		. "$( dirname $0 )/../sh-lib/DistroShellContext.include"
		DistroShellContext --distro-from-source
		
		ListSourceBuilders "$@"
	;;
esac