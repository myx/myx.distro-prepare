
if [ "`type -t ListChangedSourceProjects`" != "function" ] ; then
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-changed-source-projects.sh"
fi

for PKG in `ListChangedSourceProjects` ; do
	CHECK_FILE="$MMDAPP/source/${PKG#$MMDAPP/source/}/build.number"
	if [ -f "$CHECK_FILE" ] ; then
		echo "$PKG: INCREMENT!"
	fi
done
