#!/usr/bin/env bash

if [ -z "$MMDAPP" ] ; then
	set -e
	export MMDAPP="$( cd $(dirname "$0")/../../../.. ; pwd )"
	echo "$0: Working in: $MMDAPP"  >&2
	[ -d "$MMDAPP/source" ] || ( echo "expecting 'source' directory." >&2 && exit 1 )
fi

CleanSourceOutputs(){

	echo "Cleaning Output directory" >&2
	rm -rf "$MMDAPP/output" "$MMDAPP/cached" "$MMDAPP/export"
}

case "$0" in
	*/sh-scripts/clean-source-outputs.sh) 
		# "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/distro-source.sh" --clean-output "$MMDAPP/output" --print ""
		CleanSourceOutputs "$@"
	;;
esac