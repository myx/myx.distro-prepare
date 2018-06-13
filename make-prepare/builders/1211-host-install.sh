
if [ "`type -t ListChangedSourceProjects`" != "function" ] ; then
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-changed-source-projects.sh"
fi

for PKG in `ListChangedSourceProjects` ; do
	CHECK_DIR="$MMDAPP/source/${PKG#$MMDAPP/source/}/host/install"
	if [ -d "$CHECK_DIR" ] ; then
		echo "$PKG: HOST INSTALL!"
	fi
done
