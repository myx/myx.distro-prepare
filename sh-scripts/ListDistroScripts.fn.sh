#!/usr/bin/env bash

if [ -z "$MMDAPP" ] ; then
	set -e
	export MMDAPP="$( cd $(dirname "$0")/../../../.. ; pwd )"
	echo "$0: Working in: $MMDAPP"  >&2
	[ -d "$MMDAPP/source" ] || ( echo "expecting 'source' directory." >&2 && exit 1 )
fi

ListDistroScripts(){
	case "$1" in
		--completion)
			( \
				ListDistroScripts --type prepare ; \
				ListDistroScripts --type util ; \
				ListDistroScripts --type install ; \
			) | sort | uniq | sed "s:.fn.sh::g" 
			return 0
			;;
		--all)
			shift
			local FILTER="$MMDAPP/source/"
			case "$MDSC_OPTION" in
				--distro-from-distro)
					local MDPATH="$MMDAPP/source/myx/myx.distro-install/sh-scripts $MMDAPP/source/myx/myx.distro-util/sh-scripts $MMDAPP/source/myx/myx.distro-prepare/sh-scripts"
				;;
				--distro-from-output)
					local MDPATH="$MMDAPP/source/myx/myx.distro-util/sh-scripts $MMDAPP/source/myx/myx.distro-prepare/sh-scripts $MMDAPP/source/myx/myx.distro-install/sh-scripts"
				;;
				*)
					local MDPATH="$MMDAPP/source/myx/myx.distro-prepare/sh-scripts $MMDAPP/source/myx/myx.distro-util/sh-scripts $MMDAPP/source/myx/myx.distro-install/sh-scripts"
				;;
			esac
			;;
		--type)
			shift
			local MDTYPE="$1" ; shift
			local MDPATH="$MMDAPP/source/myx/myx.distro-$MDTYPE/sh-scripts"
			if [ ! -d "$MDPATH" ] ; then
				echo "DistroListDistroScripts: invalid type: $MDTYPE" >&2
				return 1
			fi
			local FILTER="$MDPATH/"
			;;
		*)
			local MDPATH="$MMDAPP/source/myx/myx.distro-prepare/sh-scripts"
			local FILTER="$MDPATH/"
			;;
	esac
	find \
			$MDPATH \
			 -type 'f' -name '*.sh' \
		| sed "s:^$FILTER::g" | sort
}

case "$0" in
	*/sh-scripts/ListDistroScripts.fn.sh) 
		ListDistroScripts "$@"
	;;
esac