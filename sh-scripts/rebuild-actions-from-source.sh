#!/usr/bin/env bash

if [ -z "$APP" ] ; then
	set -e
	APP="$( cd $(dirname "$0")/../../../.. ; pwd )"
	echo "$0: Working in: $APP"  >&2
	[ -d "$APP/source" ] || ( echo "expecting 'source' directory." >&2 && exit 1 )
fi

. "$APP/source/myx/myx.distro-prepare/sh-lib/lib-shell.include"


export TMP_DIR="$(mktemp -d -t "rebuild-actions-from-source-")"
if [ $? -ne 0 ]; then
	echo "Can't make temporary install directory $TMP_DIR, exiting..."
	exit 1
fi
echo "Using temporary install directory: $TMP_DIR"

echoAction(){
	local ACTION="$1"
	echo "#/bin/sh"
	echo "APP='$APP'"
	echo ". '$APP/${ACTION#$APP/}'" 
}

makeAction(){
	local FOLDER="$APP/source/$1"
	local ACTION="${2#$APP/}"
	local TARGET="$TMP_DIR/${ACTION#$FOLDER/actions/}"
	echo "Processing: ${ACTION#source/}" >&2
	mkdir -p "`dirname "$TARGET"`"
	echoAction "$ACTION" > "$TARGET"
	chmod ug=rx,o=r "$TARGET" 
}

for REPO in $( ListAllSourceRepositories ) ; do
	for PKG in $( ListAllSourceRepositoryPackages "$REPO" ) ; do
		for ACTION in $( [ -d "$APP/source/$PKG/actions" ] && find "$APP/source/$PKG/actions" -mindepth 1 -type f -name *.sh ) ; do
			makeAction "$PKG" "$ACTION"
		done
	done	
done	

rsync -rltoDCv `[ "--no-delete" = "$1" ] || echo "--delete"` --chmod=ug+rw --omit-dir-times "$TMP_DIR/" "$APP/actions"
rm -rf "$TMP_DIR"
