
if [ "`type -t SyncCacheFromSourceRepository`" != "function" ] ; then
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/sync-cache-from-source-repository.sh"
fi
if [ "`type -t DistroFromSource`" != "function" ] ; then
. "$MMDAPP/source/myx/myx.distro-prepare/sh-lib/DistroFromSource.include"
fi

PrepareSyncSourceCheckChanges(){
	for REPO in $SOURCE_REPOS ; do
		Async -2 SyncCacheFromSourceRepository "$REPO"
	done
	wait

	mkdir -p "$MMDAPP/output/distro"
	
	( \
		DistroFromSource \
			-v \
			--source-root "$MMDAPP/cached/source" \
			--output-root "$MMDAPP/output" \
			--import-from-source --select-all-from-source \
			--prepare-build-roots --prepare-build-distro-index --prepare-build-compile-index \
			--print '' \
	)
}

PrepareSyncSourceCheckChanges
