To re-create workspace environment do the following:
1) create a work directory
2) run:
	2.1) 'curl ' on mac
	2.2) 'fetch ' on bsd
3) run:
	source-prepare-build

	
	
App Folders:

/
/source - source codes
/source/repo[/group]/project - structure
/cached - build system space
/cached/source - synched source for source->distro builders
/cached/changed - package names that are changed and need to be built
/cached/built - package names that are built
/output - output products
/distro - distro structure (alternatove to /source, btw)


Project Files & Folders:

project.inf - project description file
actions/** - usable actions (predefined parameters for other scripts
make-prepare/build/* - build steps to be taken when source->distro building
make-prepare/builders/* - builders to work on project sets while building
make-install/build/* = build steps to be taken when distro->output building
make-install/builders/* - builders to work on project sets while building
sh-libs/**
sh-scripts/**

Default build steps:
1101-prepare-start-setup-environment
1200-prepare-sync-source-check-changes
1201-host-tarball ( host/tarball/** )
1201-java-compile ( java/** )
1801-actions-make ( actions/** )
1899-prepare-finished

2101-install-start-setup-environment

Default 'install' 
