
if [ "`type -t ListChangedSourceProjects`" != "function" ] ; then
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-changed-source-projects.sh"
fi
if [ "`type -t ListCachedProjectProvides`" != "function" ] ; then
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-cached-project-provides.sh"
fi

SyncExportsFromCached(){
	local PKG="${1#$MMDAPP/source/}"
	if [ -z "$PKG" ] ; then
		echo "SyncExportsFromCached: 'PKG' argument is required!" >&2 ; exit 1
	fi
	
	local SRC="$2"
	if [ -z "$SRC" ] ; then
		echo "SyncExportsFromCached: 'SRC' argument is required!" >&2 ; exit 1
	fi
	
	local DST="$3"
	if [ -z "$DST" ] ; then
		echo "SyncExportsFromCached: 'DST' argument is required!" >&2 ; exit 1
	fi
	
	local DISTRO_DIR="$MMDAPP/output/distro/$PKG"
	local SOURCE_DIR="$MMDAPP/cached/source/$PKG"
	local EXPORT_DST="$MMDAPP/output/export/$DST"

	if test -e "$DISTRO_DIR/$SRC" ; then
		printf 'sync-export: %s %s (dis) \n \t \t <= %s\n' "$PKG" "$SRC" "$DST" >&2
		mkdir -p "`dirname "$EXPORT_DST"`"
		rsync -ai --delete "$DISTRO_DIR/$SRC" "$EXPORT_DST"
		return 0
	fi
	
	if test -e "$SOURCE_DIR/$SRC" ; then
		printf 'sync-export: %s %s (src) \n \t \t <= %s\n' "$PKG" "$SRC" "$DST" >&2
		mkdir -p "`dirname "$EXPORT_DST"`"
		rsync -ai --delete "$SOURCE_DIR/$SRC" "$EXPORT_DST"
		return 0
	fi
	
	echo "ERROR: export file not found: $SRC" 
}

for PKG in `ListChangedSourceProjects` ; do
	for ITEM in `ListCachedProjectProvides "$PKG" "deploy-export"` ; do
		SyncExportsFromCached "$PKG" ` echo $ITEM | tr '\\' ' ' | sed "s,:,,g" `
	done
done
