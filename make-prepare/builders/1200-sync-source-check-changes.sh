
if [ "`type -t SyncCacheFromSourceRepository`" != "function" ] ; then
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/sync-cache-from-source-repository.sh"
fi

PrepareSyncSourceCheckChanges(){
	for REPO in $SOURCE_REPOS ; do
		Async "sync-check: $REPO" SyncCacheFromSourceRepository "$REPO"
	done
	wait
}

PrepareSyncSourceCheckChanges
