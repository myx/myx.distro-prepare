
if [ "`type -t ListChangedSourceProjects`" != "function" ] ; then
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-changed-source-projects.sh"
fi
if [ "`type -t ListCachedProjectProvides`" != "function" ] ; then
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-cached-project-provides.sh"
fi

CompileJavaSources(){
	local PKG="${1#$MMDAPP/source/}"
	if [ -z "$PKG" ] ; then
		echo "MakeProjectSourceArchive: 'PKG' argument is required!" >&2 ; exit 1
	fi

	( \
		. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/compile-project-java.sh" ; \
		CompileProjectJava $PKG \
	)
	
	return 0
	
	( \
		. "$MMDAPP/source/myx/myx.distro-prepare/sh-lib/DistroFromSource.include" ; \
		DistroFromSource \
			-v \
			--source-root "$MMDAPP/cached/source" \
			--output-root "$MMDAPP/output" \
			--import-from-source --select-all-from-source \
			--prepare-build-roots --prepare-build-distro-index --prepare-build-compile-index \
			--print '' \
	)
}

 
for PKG in `ListChangedSourceProjects` ; do
	if test ! -z "`ListCachedProjectProvides "$PKG" "build-prepare" | grep -e "^compile-java$"`" ; then
		Async "`basename "$PKG"`" CompileJavaSources "$PKG"
		wait
	fi
done
