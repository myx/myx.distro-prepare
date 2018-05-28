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
if [ "`type -t SyncCacheFromSourceProject`" != "function" ] ; then
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/sync-cache-from-source-project.sh"
fi
if [ "`type -t ListSourceRepositoryProjects`" != "function" ] ; then
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-source-repository-projects.sh"
fi

SyncCacheFromSourceRepository(){
	local REPO="${1#$MMDAPP/source/}"
	if [ -z "$REPO" ] ; then
		echo "SyncCacheFromSourceRepository: 'REPO' argument is required!" >&2 ; exit 1
	fi
	
	mkdir -p "$MMDAPP/cached/source/$REPO"
	rsync -a -i --delete "$MMDAPP/source/$REPO/repository.inf" "$MMDAPP/cached/source/$REPO/repository.inf"

	if [ -z "$PACKAGES_ALL" ] ; then
		for PKG in $PACKAGES_ALL ; do
			if [ "${PKG#$REPO/}" != "$PKG" ] ; then
				Async "`basename $PKG`" SyncCacheFromSourceProject "$PKG"
				wait
			fi
		done
	else
		for PKG in `ListSourceRepositoryProjects "$REPO"` ; do
			Async "`basename $PKG`" SyncCacheFromSourceProject "$PKG"
			wait
		done
	fi
}

case "$0" in
	*/sh-scripts/sync-cache-from-source-repository.sh) 
		SyncCacheFromSourceRepository "$@"
	;;
esac