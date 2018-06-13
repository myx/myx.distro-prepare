
if [ "`type -t ListChangedSourceProjects`" != "function" ] ; then
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-changed-source-projects.sh"
fi
if [ "`type -t ListCachedProjectProvides`" != "function" ] ; then
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-cached-project-provides.sh"
fi
if [ "`type -t ListCachedProjectSequence`" != "function" ] ; then
. "$MMDAPP/source/myx/myx.distro-prepare/sh-scripts/list-cached-project-sequence.sh"
fi

MergeScripts(){
	local PKG="${1#$MMDAPP/source/}"
	if [ -z "$PKG" ] ; then
		echo "ConcatScripts: 'PKG' argument is required!" >&2 ; exit 1
	fi
	
	local SRC_NAME="$2"
	if [ -z "$SRC_NAME" ] ; then
		echo "ConcatScripts: 'SRC_NAME' argument is required!" >&2 ; exit 1
	fi
	
	local DST_NAME="$3"
	if [ -z "$DST_NAME" ] ; then
		echo "ConcatScripts: 'DST_NAME' argument is required!" >&2 ; exit 1
	fi
	
	local DISTRO_DIR="$MMDAPP/output/distro/$PKG"
	local SOURCE_DIR="$MMDAPP/cached/source/$PKG"
	
	local OUTPUT_DST="$DISTRO_DIR/$DST_NAME"
	echo "merge: $SRC_NAME to $DST_NAME" >&2

	echo "# merged by myx.distro at `date` @ `hostname`" > "$OUTPUT_DST"
	
	for SEQUENCE in `ListCachedProjectSequence "$PKG"` ; do
		echo "sequence: $SEQUENCE" >&2
		local SRC_FILE="$MMDAPP/output/distro/$SEQUENCE/$SRC_NAME"
		if [ -f "$SRC_FILE" ] ; then
			echo "merging: $SEQUENCE/$SRC_NAME (dst)" >&2
			echo "# merged from $SEQUENCE/$SRC_NAME (dst)" >> "$OUTPUT_DST"
			cat "$SRC_FILE" >> "$OUTPUT_DST"
			continue
		fi
		local SRC_FILE="$MMDAPP/cached/source/$SEQUENCE/$SRC_NAME"
		if [ -f "$SRC_FILE" ] ; then
			echo "merging: $SEQUENCE/$SRC_NAME (src)" >&2
			echo "# merged from $SEQUENCE/$SRC_NAME (src)" >> "$OUTPUT_DST"
			cat "$SRC_FILE" >> "$OUTPUT_DST"
			continue
		fi
		
		echo "merging: $SEQUENCE/$SRC_NAME skipped (no source file)." >&2
	done
	
	echo "# end of merge " >> "$OUTPUT_DST"
}

for PKG in `ListChangedSourceProjects` ; do
	for ITEM in `ListCachedProjectProvides "$PKG" "build-prepare-merge-scripts"` ; do
		Async -2 MergeScripts "$PKG" ` echo $ITEM | tr '\\' ' ' | sed "s,:,,g" `
		wait
	done
done
