#!/usr/bin/env bash

if [ -z "$APP" ] ; then
	set -e
	APP="$( cd $(dirname "$0")/../../../.. ; pwd )"
	echo "$0: Working in: $APP"  >&2
	[ -d "$APP/source" ] || ( echo "expecting 'source' directory." >&2 && exit 1 )
fi

. "$APP/source/myx/myx.distro-prepare/sh-scripts/list-public-folders.sh"
. "$APP/source/myx/myx.distro-prepare/sh-scripts/check-echo-source-package.sh"

ListSourceRepositoryPackages(){
	local REPO_KEY="${1#$APP/source/}"
	[ -z "$REPO_KEY" ] && echo '$REPO_KEY' is not set! >&2 && exit 1
	
	for CHK_PATH in `ListPublicFolders "$APP/source/$REPO_KEY"` ; do
		for LINE in `CheckEchoSourcePackage "$CHK_PATH"` ; do
			echo "${LINE#$APP/source/}"
		done
	done	
}

case "$0" in
	*/sh-scripts/list-source-repository-packages.sh) 
		ListSourceRepositoryPackages $@
	;;
esac