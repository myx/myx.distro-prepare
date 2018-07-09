#!/usr/bin/env bash

if [ -z "$MMDAPP" ] ; then
	set -e
	export MMDAPP="$( cd $(dirname "$0")/../../../.. ; pwd )"
	echo "$0: Working in: $MMDAPP"  >&2
	[ -d "$MMDAPP/source" ] || ( echo "expecting 'source' directory." >&2 && exit 1 )
fi


ListSourceProjectBuilders(){
	local projectName="$1"
	if [ -z "$projectName" ] ; then
		echo "ListSourceProjectProvides: 'projectName' argument is required!" >&2 ; return 1
	fi
	local buildersPath="$MMDAPP/source/$projectName/make-prepare/builders"
	[ -d "$buildersPath" ] || return 0
	### only 1xxx - source-to-cached by default
	local stageFilter="${2#--}"
	for LINE in $( \
			find "$buildersPath" -mindepth 1 -type f -name $( \
					[ -z "$stageFilter" ] && echo "????-*.sh" || echo "$stageFilter???-*.sh" \
			) | sort \
		) ; do
		echo "${LINE#$MMDAPP/source/}"
	done
}

case "$0" in
	*/sh-scripts/ListSourceProjectBuilders.fn.sh)
		# ListSourceProjectBuilders myx/myx.distro-prepare 

		. "$( dirname $0 )/../sh-lib/DistroShellContext.include"
		DistroShellContext --distro-from-source
		
		ListSourceProjectBuilders "$@"
	;;
esac