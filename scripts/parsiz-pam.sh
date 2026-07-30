#!/bin/bash
# Parsİz — PAM Session Script
# LUKS konteyneri açıksa RAM ortamını mount eder

LUKS_IMG=/opt/system_data.img
MAPPER=kozmik_oda
LUKS_MOUNT=/mnt/luks_disk
RAM_MOUNT=/mnt/secure_ram
HOME_DIR=/home/lenovo

# LUKS açık mı? Direkt mount et
if [ -e /dev/mapper/$MAPPER ]; then
    mkdir -p "$LUKS_MOUNT" "$RAM_MOUNT"
    mount /dev/mapper/"$MAPPER" "$LUKS_MOUNT" 2>/dev/null
    mount -t tmpfs -o size=4G,mode=0700 tmpfs "$RAM_MOUNT" 2>/dev/null
    rsync -a --quiet "$LUKS_MOUNT"/ "$RAM_MOUNT"/ 2>/dev/null
    chown -R lenovo:lenovo "$RAM_MOUNT" 2>/dev/null
    umount "$LUKS_MOUNT" 2>/dev/null
    mount --bind "$RAM_MOUNT" "$HOME_DIR" 2>/dev/null
fi

exit 0
