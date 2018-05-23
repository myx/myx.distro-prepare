#!/usr/bin/env bash

if [ -z "$APP" ] ; then
	set -e
	APP="$( cd $(dirname "$0")/../../../.. ; pwd )"
	echo "$0: Working in: $APP"  >&2
	[ -d "$APP/source" ] || ( echo "expecting 'source' directory." >&2 && exit 1 )
fi

. "$APP/source/myx/myx.distro-prepare/sh-scripts/list-public-folders.sh"

CheckEchoSourcePackage(){
	local PKG_PATH="$1"
	[ -z "$PKG_PATH" ] && echo '$PKG_PATH' is not set! >&2 && exit 1
	[ ! -d "$PKG_PATH" ] && return 0

	local NOT_DEEP="$2"
	
	[ -f "$PKG_PATH/project.inf" ] && echo "$PKG_PATH" && return 0
	
	[ -d "$PKG_PATH/ae3-packages" ] && echo "$PKG_PATH" && return 0
	
	if [ -z "$NOT_DEEP" ] ; then
		for CHK_PATH in `ListPublicFolders "$PKG_PATH"` ; do
			CheckEchoSourcePackage "$CHK_PATH" "TRUE"
		done	
	fi
}

case "$0" in
	*/sh-scripts/check-echo-source-package.sh) 
		CheckEchoSourcePackage "$@"
	;;
esac