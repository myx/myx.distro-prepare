[ -z "$MMDAPP" ] && echo '$MMDAPP' is not set! >&2 && exit 1

CompileProjectJava(){
	local PKG="${1#$MMDAPP/source/}"
	if [ -z "$PKG" ] ; then
		echo "SyncCacheFromSourceProject: 'PKG' argument is required!" >&2 ; exit 1
	fi
	
	echo "Compiling project $PKG" >&2
	
	( \
		. "$MMDAPP/source/myx/myx.distro-prepare/sh-lib/RunJavaClassSource.include" ;
		RunJavaClassSource \
			myx/myx.distro-prepare \
			ru.myx.distro.prepare.MakeCompileSources \
			--source-root "$MMDAPP/cached/source" \
			--output-root "$MMDAPP/output" \
			--import-from-source \
			--project "$PKG" \
	)

	return 0

	rsync -azivC --exclude '*.class' --exclude '.*' --delete "$MMDAPP/cached/source/$PKG/java/" "$MMDAPP/output/cached/$PKG/java"
	
	( \
		. "$MMDAPP/source/myx/myx.distro-prepare/sh-lib/RunJavaClassSource.include" ;
		RunJavaClassSource \
			myx/myx.distro-prepare \
			ru.myx.distro.prepare.MakeCompileSources \
			--source-root "$MMDAPP/source" \
			--output-root "$MMDAPP/output" \
			--from-output \
			--project "$PKG" \
	)
}

case "$0" in
	*/sh-scripts/compile-project-java.sh) 
		# "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/distro-source.sh" --clean-output "$MMDAPP/output" --print ""
		CompileProjectJava "$@"
	;;
esac