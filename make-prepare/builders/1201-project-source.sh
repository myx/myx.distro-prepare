
if [ "`type -t ListChangedSourceProjects`" != "function" ] ; then
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-changed-source-projects.sh"
fi
if [ "`type -t ListCachedProjectProvides`" != "function" ] ; then
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-cached-project-provides.sh"
fi

MakeProjectSourceArchive(){
	local PKG="${1#$MMDAPP/source/}"
	if [ -z "$PKG" ] ; then
		echo "MakeProjectSourceArchive: 'PKG' argument is required!" >&2 ; exit 1
	fi
	
	local CHECK_DIR="$MMDAPP/cached/source/$PKG"
	local BUILT_DIR="$MMDAPP/output/distro/$PKG"
	local BASE_ROOT="`dirname "$CHECK_DIR"`"
	local PACK_ROOT="`basename "$CHECK_DIR"`"
	mkdir -p "$BUILT_DIR"
	tar -zcv -C "$BASE_ROOT" -f "$BUILT_DIR/project-source.tgz" "$PACK_ROOT"
}

for PKG in `ListChangedSourceProjects` ; do
	if test ! -z "`ListCachedProjectProvides "$PKG" "build-prepare" | grep -e "^project-source.tgz$"`" ; then
		Async "`basename "$PKG"`" MakeProjectSourceArchive "$PKG"
		wait
	fi
done
