#!/usr/bin/env bash

if [ -z "$MMDAPP" ] ; then
	set -e
	export MMDAPP="$( cd $(dirname "$0")/../../../.. ; pwd )"
	echo "$0: Working in: $MMDAPP"  >&2
	[ -d "$MMDAPP/source" ] || ( echo "expecting 'source' directory." >&2 && exit 1 )
fi

. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-public-folders.sh"
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/check-echo-source-package.sh"

ListSourceRepositoryPackages(){
	local REPO_KEY="${1#$MMDAPP/source/}"
	[ -z "$REPO_KEY" ] && echo '$REPO_KEY' is not set! >&2 && exit 1
	
	for CHK_PATH in `ListPublicFolders "$MMDAPP/source/$REPO_KEY"` ; do
		for LINE in `CheckEchoSourcePackage "$CHK_PATH"` ; do
			echo "${LINE#$MMDAPP/source/}"
		done
	done	
}

case "$0" in
	*/sh-scripts/list-source-repository-packages.sh) 
		ListSourceRepositoryPackages "$@"
	;;
esac