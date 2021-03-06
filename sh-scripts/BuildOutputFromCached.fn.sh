#!/usr/bin/env bash

if [ -z "$MMDAPP" ] ; then
	set -e
	export MMDAPP="$( cd $(dirname "$0")/../../../.. ; pwd )"
	echo "$0: Working in: $MMDAPP"  >&2
	[ -d "$MMDAPP/source" ] || ( echo "expecting 'source' directory." >&2 && exit 1 )
fi

if ! type DistroShellContext >/dev/null 2>&1 ; then
	. "$MMDAPP/source/myx/myx.distro-prepare/sh-lib/DistroShellContext.include"
fi

type Prefix >/dev/null 2>&1 || \
	. "`myx.common which lib/prefix`"

Require ListAllRepositories
Require ListAllProjects
Require ListAllBuilders


RebuildOutputFromCachedBuilderRaw(){
	set -e
	local BUILDER="$1"
	#### want to run in separate process anyways
	if ( . "$MMDAPP/source/$BUILDER" | cat -u ) ; then
		echo "done." >&2
	else
		echo "ERROR: $BUILDER failed!" >&2
	fi
}

BuildOutputFromCachedRunner(){
	set -e
	
	export BUILD_STAMP="$( date -u "+%Y%m%d%H%M%S" )"
	
	type Prefix >/dev/null 2>&1 || \
		. "`myx.common which lib/prefix`"
	
	type Async >/dev/null 2>&1 || \
		. "`myx.common which lib/async`"
	
	DistroShellContext --distro-from-cached
	
	if [ ! -d "$MDSC_SOURCE" ] ; then
		echo "ERROR: source path does not exist!" >&2
		return 1
	fi
	
	export OUTPUT_PATH="$MMDAPP/output"

	for BUILDER in $( ListAllBuilders source-process --2 ) ; do
		Prefix "c $( basename $BUILDER )" RebuildOutputFromCachedBuilderRaw "$BUILDER"
		wait
	done
}

BuildOutputFromCached(){
	set -e
	#### want to run in separate process anyways
	BuildOutputFromCachedRunner "$@" | cat -u
	wait
}

case "$0" in
	*/sh-scripts/BuildOutputFromCached.fn.sh) 
		BuildOutputFromCached "$@"
	;;
esac