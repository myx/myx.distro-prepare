#!/usr/bin/env bash

if [ -z "$MMDAPP" ] ; then
	set -e
	export MMDAPP="$( cd $(dirname "$0")/../../../.. ; pwd )"
	echo "$0: Working in: $MMDAPP"  >&2
	[ -d "$MMDAPP/source" ] || ( echo "expecting 'source' directory." >&2 && exit 1 )
fi

if [ "`type -t ListAllSourceRepositories`" != "function" ] ; then
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-all-source-repositories.sh"
fi
if [ "`type -t ListSourceRepositoryProjects`" != "function" ] ; then
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-source-repository-projects.sh"
fi


RebuildActionsFromSource(){
	local TMP_DIR="$(mktemp -d -t "rebuild-actions-from-source-")"
	if [ $? -ne 0 ]; then
		echo "Can't make temporary install directory $TMP_DIR, exiting..."
		exit 1
	fi
	echo "Using temporary install directory: $TMP_DIR"
	
	for REPO in $( ListAllSourceRepositories ) ; do
		for PKG in $( ListSourceRepositoryProjects "$REPO" ) ; do
			for ACTION in $( [ -d "$MMDAPP/source/$PKG/actions" ] && find "$MMDAPP/source/$PKG/actions" -mindepth 1 -type f -not -name '.*' ) ; do
				local PKG="${PKG#$MMDAPP/source/}"
				local ACTION="${ACTION#$MMDAPP/source/}"
				local TARGET="$TMP_DIR/${ACTION#$PKG/actions/}"
				local ACTSRC="$MMDAPP/source/${ACTION#$MMDAPP/}"
				printf %s "Processing: ${TARGET#$TMP_DIR/} \n \t \t \t <= ${ACTION#source/}\n" >&2

				mkdir -p "`dirname "$TARGET"`"

				case "$ACTION" in
			        *.sh)
						## source code of script being created:
						( echo "#/bin/sh" ; echo "export MMDAPP='$MMDAPP'" ; echo ". '$MMDAPP/source/${ACTION#$MMDAPP/}'" ) > "$TARGET"
						chmod ug=rx,o=r "$TARGET" 
						;;
			        *.url)
			        	# ( grep -q '\[InternetShortcut\]' "$ACTSRC" ) && echo "GREP=EYS"
			        	# [ "`wc -l < "$ACTSRC"`" -gt 1 ] && echo "WCS"
			        	# echo "$ACTSRC: `wc -l < "$ACTSRC"`"
						if ( grep -q '\[InternetShortcut\]' "$ACTSRC" ) || [ "`wc -l < "$ACTSRC"`" -gt 1 ] ; then
							## sym-link is being created:
							ln -fsv "$ACTSRC" "$TARGET"
							chmod -h ug=rx,o=r "$TARGET" 
						else
				        	local SRCCODE="`cat "$ACTSRC"`"
				        	if [ -f "$MMDAPP/source/$PKG/$SRCCODE" ] ; then
				        		local SRCCODE="file://$MMDAPP/source/$PKG/$SRCCODE"
				        	fi
							## source code of script being created:
							( echo "[InternetShortcut]" ; echo "URL=$SRCCODE" ; echo "WorkingDirectory=$MMDAPP/source/$PKG" ) > "$TARGET"
							chmod ug=rx,o=r "$TARGET" 
						fi 
						;;
			        *)
						## sym-link is being created:
						ln -fsv "$ACTSRC" "$TARGET"
						chmod -h ug=rx,o=r "$TARGET" 
			            ;;
				esac
			done
		done	
	done	
	
	rsync -rltoDC `[ "--no-delete" == "$1" ] || echo "--delete"` --chmod=ug+rw --omit-dir-times "$TMP_DIR/" "$MMDAPP/actions"
	rm -rf "$TMP_DIR"
}

case "$0" in
	*/sh-scripts/rebuild-actions-from-source.sh) 
		RebuildActionsFromSource "$@"
	;;
esac