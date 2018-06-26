#!/usr/bin/env bash

if [ -z "$MMDAPP" ] ; then
	set -e
	export MMDAPP="$( cd $(dirname "$0")/../../../.. ; pwd )"
	echo "$0: Working in: $MMDAPP"  >&2
	[ -d "$MMDAPP/source" ] || ( echo "expecting 'source' directory." >&2 && exit 1 )
fi

ListCachedProjectProvidesMergeSequence(){
	local PKG="$1"
	if [ -z "$PKG" ] ; then
		echo "ListCachedProjectProvides: 'PKG' argument is required!" >&2 ; exit 1
	fi

	(
		. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-cached-project-sequence.sh" ;
		for PROJECT in $( ListCachedProjectSequence "$PKG" ) ; do
			ListCachedProjectProvides "$PROJECT"
		done	
	) | uniq		
}

ListCachedProjectProvides(){
	if [ "$1" = "--merge-sequence" ] ; then
		shift
		ListCachedProjectProvidesMergeSequence "$@"
		return 0
	fi

	local PKG="$1"
	if [ -z "$PKG" ] ; then
		echo "ListCachedProjectProvides: 'PKG' argument is required!" >&2 ; exit 1
	fi
	
	local INF="$MMDAPP/output/distro/$PKG/project-index.inf"
	if [ ! -f "$INF" ] ; then
		echo "ListCachedProjectProvides: project.inf file is required (at: $INF)" >&2 ; exit 1
	fi

	local REPO="`echo $PKG | sed "s,/.*$,,g"`"
	local MTC="PRJ-PRV-${PKG#$REPO/}="
	
	local FILTER="$2"
	if test -z "$FILTER" ; then
		for ITEM in `cat "$INF" | grep "$MTC" | sed "s,^.*=,,g" | sort` ; do
			echo $ITEM
		done
	else
		for ITEM in `cat "$INF" | grep "$MTC" | sed "s,^.*=,,g" | sort` ; do
			if test "$ITEM" != "${ITEM#$FILTER\\:}" ; then
				echo ${ITEM#$FILTER\\:} | tr "|" "\n"
			fi
		done
	fi
	
}

case "$0" in
	*/sh-scripts/list-cached-project-provides.sh) 
		if [ -z "$1" ] || [ "$1" = "--help" ] ; then
			echo "syntax: list-cached-project-provides.sh [--help/--merge-sequence] <project_name>" >&2
			exit 1
		fi
		ListCachedProjectProvides "$@"
	;;
esac