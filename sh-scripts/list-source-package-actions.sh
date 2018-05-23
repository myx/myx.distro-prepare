#!/usr/bin/env bash

if [ -z "$APP" ] ; then
	set -e
	APP="$( cd $(dirname "$0")/../../../.. ; pwd )"
	echo "$0: Working in: $APP"  >&2
	[ -d "$APP/source" ] || ( echo "expecting 'source' directory." >&2 && exit 1 )
fi


ListSourcePackageActions(){
	local ACT_PATH="$APP/source/${1#$APP/source/}/actions"
	[ -d "$ACT_PATH" ] || return 0
	find "$ACT_PATH" -mindepth 1 -type f | sort
}

case "$0" in
	*/sh-scripts/list-source-package-actions.sh) 
		ListSourcePackageActions "$@"
	;;
esac