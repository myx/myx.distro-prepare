#!/bin/sh

if [ -z "$MMDAPP" ] ; then
	set -e
	export MMDAPP="$( cd $(dirname "$0")/../../../../../.. ; pwd )"
	echo "$0: Working in: $MMDAPP"  >&2
	[ -d "$MMDAPP/source" ] || ( echo "expecting 'source' directory." >&2 && exit 1 )
fi

type ListAllProjects >/dev/null 2>&1 || \
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/ListAllProjects.fn.sh"

type ListProjectProvides >/dev/null 2>&1 || \
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/ListProjectProvides.fn.sh"

for projectName in `ListAllProjects` ; do
	for ITEM in `ListProjectProvides "$projectName" "deploy-export"` ; do
		echo "$projectName: $( echo $ITEM | tr '\\' ' ' | sed "s|:| |g" )"
	done
done
