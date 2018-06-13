#!/usr/bin/env bash

if [ -z "$MMDAPP" ] ; then
	set -e
	export MMDAPP="$( cd $(dirname "$0")/../../../.. ; pwd )"
	echo "$0: Working in: $MMDAPP"  >&2
	[ -d "$MMDAPP/source" ] || ( echo "expecting 'source' directory." >&2 && exit 1 )
fi

ExtractProjectSequenceFromIndex(){
	local PKG="$1"
	if [ -z "$PKG" ] ; then
		echo "ExtractProjectSequenceFromIndex: 'PKG' argument is required!" >&2 ; exit 1
	fi
	
	local INF="$MMDAPP/output/distro/$PKG/project-index.inf"
	if [ ! -f "$INF" ] ; then
		echo "ExtractProjectSequenceFromIndex: project.inf file is required (at: $INF)" >&2 ; exit 1
	fi

	local REPO="`echo $PKG | sed "s,/.*$,,g"`"
	local MTC="PRJ-SEQ-${PKG#$REPO/}="
	
	local RESULT=""

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

ListCachedProjectSequence(){
	local PKG="$1"
	if [ -z "$PKG" ] ; then
		echo "ListCachedProjectSequence: 'PKG' argument is required!" >&2 ; exit 1
	fi
	
	local INF="$MMDAPP/output/distro/$PKG/project-build-sequence.inf"
	if [ -f "$INF" ] ; then
		cat "$INF"
		return 0
	fi

	if [ "$2" = "--no-write" ] ; then
		ExtractProjectSequenceFromIndex "$PKG"
		return 0
	fi
	
	local OUTPUT="`ExtractProjectSequenceFromIndex "$PKG"`"
	echo "$OUTPUT" > "$INF"
	echo "$OUTPUT"
}

case "$0" in
	*/sh-scripts/list-cached-project-sequence.sh) 
		ListCachedProjectSequence "$@"
	;;
esac