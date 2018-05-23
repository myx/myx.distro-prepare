#!/usr/bin/env bash

if [ -z "$APP" ] ; then
	set -e
	APP="$( cd $(dirname "$0")/../../../.. ; pwd )"
	echo "$0: Working in: $APP"  >&2
	[ -d "$APP/source" ] || ( echo "expecting 'source' directory." >&2 && exit 1 )
fi

ListAllSourceRepositories(){
	for LINE in `find "$APP/source" -mindepth 2 -maxdepth 2 -name repository.inf | sort | sed 's!/repository.inf$!!'` ; do
		echo "${LINE#$APP/source/}"
	done
}

case "$0" in
	*/sh-scripts/list-all-source-repositories.sh) 
		ListAllSourceRepositories $@
	;;
esac