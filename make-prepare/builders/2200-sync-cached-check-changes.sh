if [ "`type -t DistroSourceCommand`" != "function" ] ; then
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/DistroSourceCommand.fn.sh"
fi

Require DistroSourceCommand

mkdir -p "$MMDAPP/output/distro"

( \
	DistroSourceCommand \
		-v \
		--output-root "$MMDAPP/output" \
		--source-root "$MMDAPP/cached/sources" \
		--cached-root "$MMDAPP/output/cached" \
		--import-from-source --select-all-from-source \
		--print ''  -v \
		--prepare-build \
		--print '' \
)

#			--prepare-build-roots --prepare-build-compile-index --prepare-build-distro-index \
#			--prepare-build-roots --prepare-build-compile-index --prepare-build-distro-index --prepare-build-fetch-missing \
