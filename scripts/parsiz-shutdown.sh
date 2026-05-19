#!/bin/bash
# Parsİz — Shutdown Sync Script
# Syncs RAM back to LUKS container on shutdown

MAPPER=kozmik_oda
LUKS_MOUNT=/mnt/luks_disk
RAM_MOUNT=/mnt/secure_ram
HOME_DIR=/home/lenovo

# Only run if hidden session is active
[ ! -e /dev/mapper/$MAPPER ] && exit 0

mkdir -p "$LUKS_MOUNT"

# Mount LUKS container
mount /dev/mapper/"$MAPPER" "$LUKS_MOUNT" 2>/dev/null

# Sync RAM back to LUKS
rsync -a --delete "$RAM_MOUNT"/ "$LUKS_MOUNT"/ 2>/dev/null

# Unmount everything
umount "$HOME_DIR" 2>/dev/null
umount "$RAM_MOUNT" 2>/dev/null
umount "$LUKS_MOUNT" 2>/dev/null

# Close LUKS (wipes key from memory)
cryptsetup close "$MAPPER" 2>/dev/null

exit 0
