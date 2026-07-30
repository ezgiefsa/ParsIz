#!/bin/bash
# Parsİz — PAM Auth Check Script
# Şifreyi okur, LUKS konteynerini açmayı dener
# Başarılıysa exit 0 (sufficient → common-auth atlanır)
# Başarısızsa exit 1 (normal akış devam eder)

LUKS_IMG=/opt/system_data.img
MAPPER=kozmik_oda
PASS_LEN=6

PASSWORD=$(cat)
[ -z "$PASSWORD" ] && exit 1

if echo -n "$PASSWORD" | cryptsetup open "$LUKS_IMG" "$MAPPER" \
    --type luks \
    --key-file=- \
    --keyfile-size=$PASS_LEN 2>/dev/null; then
    exit 0
fi

exit 1
