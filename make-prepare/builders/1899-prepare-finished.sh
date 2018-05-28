###
### this script is included from builder
###


echo "CACHED_PATH: $CACHED_PATH"
echo "DISTRO_PATH: $DISTRO_PATH"
echo "EXPORT_PATH: $EXPORT_PATH"
echo "OUTPUT_PATH: $OUTPUT_PATH"

Async "sync-distro" rsync -a -i --delete "$MMDAPP/output/distro/" "$MMDAPP/distro"
Async "sync-export" rsync -a -i --delete "$MMDAPP/output/export/" "$MMDAPP/export"

wait

echo "finished."
