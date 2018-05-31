[ -z "$MMDAPP" ] && echo '$MMDAPP' is not set! >&2 && exit 1

CompileRepositoryJava(){
	REPO_NAME=$1; shift
	REPO_JAVA="$MMDAPP/output/cached/$REPO_NAME"

	echo "Compiling repository $REPO_NAME" >&2


	( \
		. "$MMDAPP/source/myx/myx.distro-prepare/sh-lib/RunJavaClassSource.include" ;
		RunJavaClassSource \
			myx/myx.distro-prepare \
			ru.myx.distro.prepare.MakeCompileSources \
			"$MMDAPP/source" \
			"$MMDAPP/output" \
			--repository "$REPO_NAME" \
	)
}

case "$0" in
	*/sh-scripts/compile-repository-java.sh) 
		# "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/distro-source.sh" --clean-output "$MMDAPP/output" --print ""
		CompileRepositoryJava "$@"
	;;
esac