#/bin/sh

if [ -z "$MMDAPP" ] ; then
	set -e
	export MMDAPP="$( cd $(dirname "$0")/../../../.. ; pwd )"
	echo "$0: Working in: $MMDAPP"  >&2
	[ -d "$MMDAPP/source" ] || ( echo "expecting 'source' directory." >&2 && exit 1 )
fi

. "$MMDAPP/source/myx/myx.distro-prepare/sh-lib/DistroFromSource.include"

DistroFromSource \
	--source-root "$MMDAPP/source" \
	--output-root "$MMDAPP/output" \
	"$@" \
	--print ''


exit 0

######################
######################
###
###   Examples:
###   Source:
###

./distro/distro-source-prepare-output.command

./distro/distro-source.sh
./distro/distro-source.sh --import-from-source --print-projects

./distro/distro-source.sh --clean-output ../output -p ""

./distro/distro-source.sh -v --add-all-source-repositories ../source --print-repositories -p ""
./distro/distro-source.sh -v --add-all-source-repositories ../source --print-projects -p ""

./distro/distro-source.sh -v --add-source-repository ../source/myx --add-source-repository ../source/ndm --print-repositories -p ""
./distro/distro-source.sh -v --add-source-repository ../source/myx --add-remote-repository "ndm|http://myx.ru/distro/ndm" --print-repositories -p ""

./distro/distro-source.sh -v --add-all-source-repositories ../source  --prepare-build -p ""
./distro/distro-source.sh -v --import-from-source --prepare-build -p ""

./distro/distro-source.sh --import-from-source --prepare-sequence --select-all-from-source --print-selected

./distro/distro-source.sh --import-from-source --prepare-build --print '' --print-project-build-classpath ae3.sdk 
./distro/distro-source.sh --import-from-source --prepare-build --print '' --print-project-build-classpath myx.distro-util

./distro/distro-source.sh --import-from-source --prepare-build --print '' -vv --run-java-from-project myx.distro-util ru.myx.distro.MakePackagesFromFolders --done --print-project-build-classpath ae3.sdk 

./distro/distro-source.sh --import-from-source --prepare-build --select-all-from-source --print '' -vv --run-java-from-project myx.distro-util ru.myx.distro.MakePackagesFromFolders --done --print-project-build-classpath ae3.sdk 

./distro/distro-source.sh --import-from-source --prepare-build --select-all-from-source -vv --run-java-from-project myx.distro-util ru.myx.distro.MakePackagesFromFolders

./distro/distro-source.sh --import-from-source --prepare-build --select-all-from-source --make-packages-from-folders --sync-distro-from-cached

./distro/distro-source.sh --import-from-source --build-distro-from-sources
./distro/distro-source.sh --import-from-source --build-distro-from-sources -p ""


./distro/distro-source.sh -vv --run-java-from-project myx.distro-prepare ru.myx.distro.FolderScanCommand
