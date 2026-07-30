#!/bin/bash
# Parsİz — Otomatik Kurulum Scripti
# Pardus 23 XFCE üzerinde çalışır
# Kullanım: sudo bash install.sh

set -e

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()    { echo -e "${GREEN}[+]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[X]${NC} $1"; exit 1; }

# Root kontrolü
[ "$EUID" -ne 0 ] && error "Bu script root olarak çalıştırılmalıdır: sudo bash install.sh"

# Pardus 23 kontrolü
[ ! -f /etc/pardus-release ] && warn "Pardus 23 dışında bir sistem tespit edildi. Devam ediliyor..."

info "Parsİz kurulumu başlıyor..."

# Gerekli paketler
info "Gerekli paketler kontrol ediliyor..."
apt-get install -y cryptsetup rsync 2>/dev/null || error "Paket kurulumu başarısız"

# Kullanıcı adı
USERNAME=${SUDO_USER:-lenovo}
info "Kullanıcı: $USERNAME"

# LUKS imajı
LUKS_IMG=/opt/system_data.img
if [ -f "$LUKS_IMG" ]; then
    warn "$LUKS_IMG zaten mevcut, atlanıyor..."
else
    info "20 GB LUKS imajı oluşturuluyor (birkaç dakika sürebilir)..."
    dd if=/dev/zero of="$LUKS_IMG" bs=1M count=20480 status=progress
    info "LUKS şifreleme yapılandırılıyor..."
    warn "Şimdi GİZLİ şifrenizi belirleyeceksiniz. Bu şifreyi unutmayın!"
    cryptsetup luksFormat "$LUKS_IMG"
    info "LUKS konteyneri biçimlendiriliyor..."
    cryptsetup open "$LUKS_IMG" parsiz_setup
    mkfs.ext4 /dev/mapper/parsiz_setup
    mkdir -p /mnt/parsiz_setup
    mount /dev/mapper/parsiz_setup /mnt/parsiz_setup
    mkdir -p /mnt/parsiz_setup/{Belgeler,Masaüstü,İndirilenler,Resimler,Müzik,Videolar}
    chown -R "$USERNAME:$USERNAME" /mnt/parsiz_setup
    umount /mnt/parsiz_setup
    cryptsetup close parsiz_setup
    chmod 600 "$LUKS_IMG"
    chown root:root "$LUKS_IMG"
    info "LUKS imajı hazır: $LUKS_IMG"
fi

# Dizinler
mkdir -p /mnt/luks_disk /mnt/secure_ram

# Scriptleri kur
info "Scriptler kuruluyor..."
cp scripts/parsiz-check.sh /usr/local/bin/parsiz-check.sh
cp scripts/parsiz-pam.sh /usr/local/bin/parsiz-pam.sh
cp scripts/parsiz-shutdown.sh /usr/local/bin/parsiz-shutdown.sh
chmod 700 /usr/local/bin/parsiz-*.sh
chown root:root /usr/local/bin/parsiz-*.sh

# LightDM yapılandırması
info "LightDM yapılandırılıyor..."
cp /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.YEDEK 2>/dev/null || true
cat > /etc/lightdm/lightdm.conf << 'LIGHTDM'
[LightDM]

[Seat:*]
greeter-session=lightdm-gtk-greeter
pam-service=lightdm

[XDMCPServer]

[VNCServer]
LIGHTDM

# PAM yapılandırması
info "PAM yapılandırılıyor..."
cp /etc/pam.d/lightdm /etc/pam.d/lightdm.YEDEK
cp config/pam.lightdm /etc/pam.d/lightdm

# systemd servisi
info "systemd servisi kuruluyor..."
cp config/stealth-sync.service /etc/systemd/system/stealth-sync.service
systemctl daemon-reload
systemctl enable stealth-sync.service

# Hibernate ve swap devre dışı
info "Hibernate ve swap devre dışı bırakılıyor..."
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
swapoff -a 2>/dev/null || true

info ""
info "=========================================="
info "Parsİz kurulumu tamamlandı!"
info "=========================================="
info ""
info "Normal şifre  → Standart Pardus masaüstü"
info "Gizli şifre   → Gizli oturum (RAM'de)"
info ""
warn "UYARI: Gizli oturumda asla uyku/hibernate kullanmayın!"
warn "UYARI: Sadece 'sudo systemctl poweroff' ile kapatın!"
info ""
info "Sistemi yeniden başlatın: sudo reboot"
