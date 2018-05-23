#!/usr/bin/env bash

if [ -z "$APP" ] ; then
	set -e
	APP="$( cd $(dirname "$0")/../../../.. ; pwd )"
	echo "$0: Working in: $APP"  >&2
	[ -d "$APP/source" ] || ( echo "expecting 'source' directory." >&2 && exit 1 )
fi

. "$APP/source/myx/myx.distro-prepare/sh-scripts/list-all-source-repositories.sh"
. "$APP/source/myx/myx.distro-prepare/sh-scripts/list-source-repository-packages.sh"
. "$APP/source/myx/myx.distro-prepare/sh-scripts/list-source-package-actions.sh"


ListAllSourceRepositoryActions(){
	local REPO_KEY="${1#$APP/source/}"
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