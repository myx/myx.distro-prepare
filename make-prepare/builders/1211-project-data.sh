
if [ "`type -t ListChangedSourceProjects`" != "function" ] ; then
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-changed-source-projects.sh"
fi

CheckMakeProjectDataFolder(){
	local PKG="${1#$MMDAPP/source/}"
	local CHECK_DIR="$MMDAPP/cached/source/$PKG/data"
	if [ -d "$CHECK_DIR" ] ; then
		local BUILT_DIR="$MMDAPP/output/distro/$PKG"
		mkdir -p "$BUILT_DIR"
		tar -cvj -C "$CHECK_DIR" -f "$BUILT_DIR/data.tbz" "./"
	fi
}

for PKG in `ListChangedSourceProjects` ; do
	Async "`basename "$PKG"`" CheckMakeProjectDataFolder "$PKG"
	wait
done
