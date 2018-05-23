#!/usr/bin/env bash

if [ -z "$APP" ] ; then
	set -e
	APP="$( cd $(dirname "$0")/../../../.. ; pwd )"
	echo "$0: Working in: $APP"  >&2
	[ -d "$APP/source" ] || ( echo "expecting 'source' directory." >&2 && exit 1 )
fi

. "$APP/source/myx/myx.distro-prepare/sh-scripts/list-all-source-repositories.sh"
. "$APP/source/myx/myx.distro-prepare/sh-scripts/list-source-repository-packages.sh"


RebuildActionsFromSource(){
	export TMP_DIR="$(mktemp -d -t "rebuild-actions-from-source-")"
	if [ $? -ne 0 ]; then
		echo "Can't make temporary install directory $TMP_DIR, exiting..."
		exit 1
	fi
	echo "Using temporary install directory: $TMP_DIR"
	
	for REPO in $( ListAllSourceRepositories ) ; do
		for PKG in $( ListSourceRepositoryPackages "$REPO" ) ; do
			for ACTION in $( [ -d "$APP/source/$PKG/actions" ] && find "$APP/source/$PKG/actions" -mindepth 1 -type f -name *.sh ) ; do
				local PKG="${PKG#$APP/source/}"
				local ACTION="${ACTION#$APP/source/}"
				local TARGET="$TMP_DIR/${ACTION#$PKG/actions/}"
				echo "Processing: ${ACTION#source/} -> ${TARGET#$TMP_DIR/}" >&2
				mkdir -p "`dirname "$TARGET"`"
				
				## source code of script being created:
				( echo "#/bin/sh" ; echo "APP='$APP'" ; echo ". '$APP/source/${ACTION#$APP/}'" ) > "$TARGET"
				
				chmod ug=rx,o=r "$TARGET" 
			done
		done	
	done	
	
	rsync -rltoDCv `[ "--no-delete" = "$1" ] || echo "--delete"` --chmod=ug+rw --omit-dir-times "$TMP_DIR/" "$APP/actions"
	rm -rf "$TMP_DIR"
}

case "$0" in
	*/sh-scripts/rebuild-actions-from-source.sh) 
		RebuildActionsFromSource $@
	;;
esac