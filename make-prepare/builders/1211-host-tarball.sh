
if [ "`type -t ListChangedSourceProjects`" != "function" ] ; then
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-changed-source-projects.sh"
fi
if [ "`type -t ListCachedProjectProvides`" != "function" ] ; then
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-cached-project-provides.sh"
fi

CheckMakeProjectHostTarball(){
	local PKG="${1#$MMDAPP/source/}"
	if [ -z "$PKG" ] ; then
		echo "CheckMakeProjectHostTarball: 'PKG' argument is required!" >&2 ; exit 1
	fi
	
	local SRC="$MMDAPP/cached/source/$PKG"
	
	if [ -d "$SRC/host/tarball" ] ; then
		local BUILT_DIR="$MMDAPP/output/distro/$PKG"
		local PACK_ROOT="`basename "$PKG"`"
		mkdir -p "$BUILT_DIR"
		
		( \
			cd "$SRC/.." ; \
			tar -cvj \
				-f "$BUILT_DIR/host-tarball.tbz" \
				` [ ! -d "$SRC/host-freebsd/tarball" ] || echo "$PACK_ROOT/host-freebsd/tarball" ` \
				` [ ! -d "$SRC/host-macosx/tarball" ]  || echo "$PACK_ROOT/host-macosx/tarball" ` \
				` [ ! -d "$SRC/host-ubuntu/tarball" ]  || echo "$PACK_ROOT/host-ubuntu/tarball" ` \
				"$PACK_ROOT/host/tarball"
		)
	 
	 
		echo done.
	fi
}

for PKG in `ListChangedSourceProjects` ; do
	if test ! -z "`ListCachedProjectProvides "$PKG" "build-prepare" | grep -e "^host-tarball.tbz$"`" ; then
		Async "`basename "$PKG"`" CheckMakeProjectHostTarball "$PKG"
		wait
	fi
done
