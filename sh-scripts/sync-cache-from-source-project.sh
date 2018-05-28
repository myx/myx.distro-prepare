#!/usr/bin/env bash

if [ -z "$MMDAPP" ] ; then
	set -e
	export MMDAPP="$( cd $(dirname "$0")/../../../.. ; pwd )"
	echo "$0: Working in: $MMDAPP"  >&2
	[ -d "$MMDAPP/source" ] || ( echo "expecting 'source' directory." >&2 && exit 1 )
fi

if [ -z "`which rsync`" ] ; then
	echo "$0: rsync is required!" >&2
	exit 1
fi

if [ "`type -t Async`" != "function" ] ; then
. "`myx.common which lib/async`"
fi

SyncCacheFromSourceProject(){
	local PKG="${1#$MMDAPP/source/}"
	if [ -z "$PKG" ] ; then
		echo "SyncCacheFromSourceProject: 'PKG' argument is required!" >&2 ; exit 1
	fi
	
	local SRC="$MMDAPP/source/$PKG"

	local DST="$MMDAPP/cached/source/$PKG"
	mkdir -p "$DST"

	local CHG="$MMDAPP/cached/changed/$PKG"
	if [ -f "$CHG" ] ; then
		echo "already marked as changed." 
	fi
	
	if local ROUTPUT="`rsync -a -i --delete --exclude '.*' --exclude 'CVS' "$SRC/" "$DST"`" ; then
		if [ -z "$ROUTPUT" ] ; then
			echo "not changed on this run."
		else
			echo "$ROUTPUT"
			mkdir -p "`dirname "$CHG"`"
			touch "$CHG"
			echo "changed."
		fi
	else
		echo "ERROR: $ROUTPUT"
	fi
}

case "$0" in
	*/sh-scripts/sync-cache-from-source-project.sh) 
		SyncCacheFromSourceProject "$@"
	;;
esac