#!/usr/bin/env bash

if [ -z "$MMDAPP" ] ; then
	set -e
	export MMDAPP="$( cd $(dirname "$0")/../../../.. ; pwd )"
	echo "$0: Working in: $MMDAPP"  >&2
	[ -d "$MMDAPP/source" ] || ( echo "expecting 'source' directory." >&2 && exit 1 )
fi

CleanOutputToDistro(){

	echo "Cleaning Output directory" >&2
	rm -rf "$MMDAPP/export" "$MMDAPP/distro"
	
	if type DistroShellContext >/dev/null 2>&1 ; then
		echo "Cleaning DistroShell in-line caches" >&2
		DistroShellContext --uncache
	fi
}

case "$0" in
	*/sh-scripts/CleanOutputToDistro.fn.sh) 
		# "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/distro-source.sh" --clean-output "$MMDAPP/output" --print ""
		CleanOutputToDistro "$@"
	;;
esac