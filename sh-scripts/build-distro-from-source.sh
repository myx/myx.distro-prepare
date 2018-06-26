#!/usr/bin/env bash

if [ -z "$MMDAPP" ] ; then
	set -e
	export MMDAPP="$( cd $(dirname "$0")/../../../.. ; pwd )"
	echo "$0: Working in: $MMDAPP"  >&2
	[ -d "$MMDAPP/source" ] || ( echo "expecting 'source' directory." >&2 && exit 1 )
fi

type Async >/dev/null 2>&1 || \
	. "`myx.common which lib/async`"

. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-all-source-repositories.sh"
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-all-source-projects.sh"
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-all-source-builders.sh"

export SOURCE_REPOS="`ListAllSourceRepositories`"
export PACKAGES_ALL="`ListAllSourceProjects`"
export BUILDERS_ALL="`ListAllSourceBuilders`"

if [ -z "$CACHED_PATH" ] ; then
	export CACHED_PATH="$MMDAPP/cached"
fi
if [ -z "$DISTRO_PATH" ] ; then
	export DISTRO_PATH="$MMDAPP/distro"
fi
if [ -z "$EXPORT_PATH" ] ; then
	export EXPORT_PATH="$MMDAPP/export"
fi
if [ -z "$OUTPUT_PATH" ] ; then
	export OUTPUT_PATH="$MMDAPP/output"
fi

RebuildDistroFromSourceBuilderRaw(){
	local BUILDER="$1"
	if ( . "$MMDAPP/source/$BUILDER" | cat ) ; then
		echo "done."
	else
		echo "ERROR: $BUILDER failed!" >&2
	fi
}

RebuildDistroFromSourceRaw(){
	echo "Will check for changes"
	for BUILDER in $BUILDERS_ALL ; do
		Async "`basename $BUILDER`" RebuildDistroFromSourceBuilderRaw "$BUILDER"
		wait
	done
}

BuildDistroFromSource(){
	Async "prepare" RebuildDistroFromSourceRaw "$@"
	wait
}

case "$0" in
	*/sh-scripts/build-distro-from-source.sh) 
		BuildDistroFromSource "$@"
	;;
esac