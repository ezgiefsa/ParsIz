#!/bin/bash
# Parsİz — Shutdown Sync Script
# Kapanışta RAM'i LUKS'a kaydeder, izleri temizler

MAPPER=kozmik_oda
LUKS_MOUNT=/mnt/luks_disk
RAM_MOUNT=/mnt/secure_ram
HOME_DIR=/home/lenovo

# Gizli oturum aktif değilse çık
[ ! -e /dev/mapper/$MAPPER ] && exit 0

mkdir -p "$LUKS_MOUNT"

# LUKS'u mount et
mount /dev/mapper/"$MAPPER" "$LUKS_MOUNT" 2>/dev/null

# RAM'den diske kaydet
rsync -a --delete "$RAM_MOUNT"/ "$LUKS_MOUNT"/ 2>/dev/null

# Bağlantıları çöz
umount "$HOME_DIR" 2>/dev/null
umount "$RAM_MOUNT" 2>/dev/null
umount "$LUKS_MOUNT" 2>/dev/null

# LUKS kapat (anahtar bellekten silinir)
cryptsetup close "$MAPPER" 2>/dev/null

exit 0
