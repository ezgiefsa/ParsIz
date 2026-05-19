# Parsİz — İnkar Edilebilir İşletim Sistemi

> **TEKNOFEST 2026 — Pardus Geliştirme Kategorisi**  
> Pardus 23 XFCE üzerine inşa edilmiş, gizlilik odaklı inkar edilebilir işletim sistemi mimarisi

---

## 📌 Parsİz Nedir?

Parsİz, Pardus 23 üzerine inşa edilmiş bir inkar edilebilir işletim sistemi mimarisidir. Tek bir bilgisayarın, giriş ekranında girilen şifreye göre iki tamamen farklı modda çalışmasını sağlar:

| Giriş Şifresi | Sonuç |
|---------------|-------|
| Normal şifre | Standart Pardus masaüstü — gizli sistemden iz yok |
| Kozmik şifre | Gizli masaüstü — dosyalar şifreli LUKS konteynerinden RAM'e yüklenir |
| Yanlış şifre | Standart kimlik doğrulama hatası |

Gizli oturum kapandıktan sonra diskte **hiçbir iz kalmaz**. Tüm veriler oturum süresince RAM'de yaşar; yalnızca kapanışta şifreli konteynere geri yazılır.

> **Yapay zekâ kullanımı hakkında:** Bu sistemi biz tasarladık. Yapay zekâyı araştırma ve bazı kod bloklarını hızlandırmak için kullandık, ancak sistem tasarımı ve entegrasyon tamamen bize ait.

---

## 🏗️ Mimari

```
Giriş Ekranı (LightDM + GTK Greeter)
        │
        ▼
   PAM Kimlik Doğrulama Zinciri
        │
        ├── Normal Şifre ─────────────────► Standart Pardus Masaüstü
        │                                   /home/lenovo (gerçek disk)
        │
        └── Kozmik Şifre
                │
                ▼
         stealthkernel-check.sh
         (cryptsetup ile LUKS konteynerini açar)
                │
                ▼
         stealthkernel-pam.sh (oturum aşaması)
         ├── LUKS → /mnt/luks_disk mount
         ├── tmpfs (RAM diski) → /mnt/secure_ram oluştur
         ├── rsync LUKS içeriği → RAM
         ├── RAM sahipliğini kullanıcıya ver
         └── RAM → /home/lenovo bind mount
                │
                ▼
         Gizli Masaüstü
         (Tüm dosyalar RAM'de, diske şifresiz yazılmaz)
                │
                ▼
         Kapanış → stealth-shutdown.sh
         ├── LUKS → /mnt/luks_disk mount et
         ├── rsync RAM → LUKS (tüm değişiklikleri kaydet)
         ├── umount /home/lenovo
         ├── umount /mnt/secure_ram
         ├── umount /mnt/luks_disk
         ├── cryptsetup close (anahtar bellekten silindi)
         └── Logları temizle
```

---

## 🔐 Güvenlik Modeli

| Tehdit | Koruma Seviyesi | Açıklama |
|--------|----------------|----------|
| Uzaktan dijital saldırı | ✅ Yüksek | LUKS şifreli konteyner |
| Fiziksel el koyma (kapalı) | ✅ Yüksek | Disk şifreli, anahtar diskte yok |
| Fiziksel zorlama (rubber-hose) | ✅ Yüksek | Normal şifre masum sistemi açar |
| Adli disk incelemesi | ✅ Yüksek | Kozmik şifre olmadan LUKS okunamaz |
| Cold boot saldırısı | ⚠️ Kısmi | RAM temizleme penceresi ~saniyeler |
| Uyku / Hibernate | ✅ Devre dışı | systemctl ile maskelendi |
| Swap | ✅ Devre dışı | Swap partition yok |

---

## 📁 Repo Yapısı

```
Parsİz/
├── README.md                    # İngilizce dokümantasyon
├── README.tr.md                 # Bu dosya (Türkçe)
├── install.sh                   # Otomatik kurulum scripti
├── scripts/
│   ├── stealthkernel-check.sh   # PAM auth: kozmik şifrede LUKS açar
│   ├── stealthkernel-pam.sh     # PAM session: RAM ortamını mount eder
│   └── stealth-shutdown.sh      # Kapanış: RAM → LUKS sync, iz temizle
├── config/
│   ├── lightdm.conf             # LightDM yapılandırması (GTK greeter)
│   ├── pam.lightdm              # PAM yapılandırması
│   └── stealth-sync.service     # systemd kapanış sync servisi
├── tests/
│   ├── test_normal_login.md     # Test: normal şifre girişi
│   ├── test_hidden_login.md     # Test: kozmik şifre girişi
│   ├── test_persistence.md      # Test: yeniden başlatmada veri kalıcılığı
│   └── test_security.md         # Test: güvenlik kontrolleri
└── docs/
    ├── architecture.md          # Detaylı mimari dokümantasyon
    └── threat_model.md          # Tehdit modeli analizi
```

---

## ⚙️ Gereksinimler

- Pardus 23 XFCE (temiz kurulum önerilir)
- `cryptsetup` >= 2.6
- `rsync` >= 3.2
- Minimum 4 GB RAM (tmpfs tahsisi)
- Minimum 25 GB boş disk alanı (LUKS konteyneri)

---

## 🚀 Kurulum

```bash
# Repoyu klonla
git clone https://github.com/ezgiefsa/Parsiz.git
cd Parsiz

# Kurulum scriptini çalıştır
sudo bash install.sh
```

Kurulum scripti şunları yapar:
1. `/opt/system_data.img` konumunda 20 GB LUKS şifreli konteyner oluşturur
2. PAM kimlik doğrulama scriptlerini kurar
3. LightDM'i GTK greeter ile yapılandırır
4. systemd kapanış sync servisini etkinleştirir
5. Swap ve hibernate'i devre dışı bırakır

---

## 🧪 Test Sonuçları

| Test | Beklenen Sonuç | Durum |
|------|---------------|-------|
| Normal giriş | Standart Pardus masaüstü, gizli iz yok | ✅ Geçti |
| Kozmik giriş | Gizli masaüstü, `/home/lenovo` RAM mount edildi | ✅ Geçti |
| Yanlış şifre | Kimlik doğrulama hatası | ✅ Geçti |
| Dosya kalıcılığı | Dosyalar kapanışta LUKS'a kaydedilir | ✅ Geçti |
| Kozmik sonrası normal giriş | Gizli dosyalar görünmüyor | ✅ Geçti |
| Hibernate denemesi | Engellendi (systemd tarafından maskelendi) | ✅ Geçti |
| Swap kontrolü | Aktif swap yok | ✅ Geçti |
| LUKS bütünlüğü | Kozmik şifre olmadan konteyner okunamaz | ✅ Geçti |

---

## ⚠️ Önemli Güvenlik Notları

1. **Gizli oturumda asla uyku/hibernate kullanma** — sadece tam kapatma (`sudo systemctl poweroff`)
2. **Gizli oturumda ekran kilidi kullanma** — çıkış yap
3. **Kozmik şifre asla yazıya dökülmemeli**
4. **LUKS konteynerini periyodik olarak** harici şifreli sürücüye yedekle
5. **Kozmik şifre unutulursa** — veriler kalıcı olarak erişilemez (tasarım gereği)

---

## 👥 Ekip

| İsim | Rol |
|------|-----|
| Ebubekir Yılmaz | Geliştirici |
| Ezgi Efsa Güleç | Proje Lideri & Baş Geliştirici |
| Fatma Zehra Osmanoğlu | Geliştirici |

---

## 📄 Lisans

Bu proje **TEKNOFEST 2026 — Pardus Geliştirme Kategorisi** için geliştirilmiştir.

---

*Parsİz — Çünkü gizlilik bir suç değil, bir haktır.*
