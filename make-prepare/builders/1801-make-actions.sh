
if [ "`type -t RebuildActionsFromSource`" != "function" ] ; then
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/rebuild-actions-from-source.sh"
fi

RebuildActionsFromSource --no-delete
