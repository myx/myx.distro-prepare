#!/usr/bin/env bash

if [ -z "$MMDAPP" ] ; then
	set -e
	export MMDAPP="$( cd $(dirname "$0")/../../../.. ; pwd )"
	echo "$0: Working in: $MMDAPP"  >&2
	[ -d "$MMDAPP/source" ] || ( echo "expecting 'source' directory." >&2 && exit 1 )
fi

ListAllSourceRepositories(){
	for LINE in `find "$MMDAPP/source" -mindepth 2 -maxdepth 2 -name repository.inf | sort | sed 's!/repository.inf$!!'` ; do
		echo "${LINE#$MMDAPP/source/}"
	done
}

case "$0" in
	*/sh-scripts/list-all-source-repositories.sh) 
		ListAllSourceRepositories "$@"
	;;
esac