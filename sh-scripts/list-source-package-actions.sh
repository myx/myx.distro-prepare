#!/usr/bin/env bash

if [ -z "$MMDAPP" ] ; then
	set -e
	export MMDAPP="$( cd $(dirname "$0")/../../../.. ; pwd )"
	echo "$0: Working in: $MMDAPP"  >&2
	[ -d "$MMDAPP/source" ] || ( echo "expecting 'source' directory." >&2 && exit 1 )
fi


ListSourcePackageActions(){
	local ACT_PATH="$MMDAPP/source/${1#$MMDAPP/source/}/actions"
	[ -d "$ACT_PATH" ] || return 0
	find "$ACT_PATH" -mindepth 1 -type f | sort
}

case "$0" in
	*/sh-scripts/list-source-package-actions.sh) 
		ListSourcePackageActions "$@"
	;;
esac