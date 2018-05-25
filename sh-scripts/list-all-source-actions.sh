#!/usr/bin/env bash

if [ -z "$MMDAPP" ] ; then
	set -e
	export MMDAPP="$( cd $(dirname "$0")/../../../.. ; pwd )"
	echo "$0: Working in: $MMDAPP"  >&2
	[ -d "$MMDAPP/source" ] || ( echo "expecting 'source' directory." >&2 && exit 1 )
fi

. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-all-source-repositories.sh"
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-source-repository-packages.sh"
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-source-package-actions.sh"


ListAllSourceRepositoryActions(){
	local REPO_KEY="${1#$MMDAPP/source/}"
	[ -z "$REPO_KEY" ] && echo '$REPO_KEY' is not set! >&2 && exit 1

	for PKG in $( ListSourceRepositoryPackages "$REPO_KEY" ) ; do
		ListSourcePackageActions "$PKG"
	done	
}

ListAllSourceActions(){
	for REPO in $( ListAllSourceRepositories ) ; do
		ListAllSourceRepositoryActions "$REPO"
	done	
}

case "$0" in
	*/sh-scripts/list-all-source-actions.sh) 
		ListAllSourceActions
	;;
esac