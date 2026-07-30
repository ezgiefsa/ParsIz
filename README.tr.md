# Parsİz — Pardus için Amnezik Gizli Oturum

> **TEKNOFEST 2026 — Pardus Geliştirme Kategorisi**  
> Pardus 23 XFCE üzerine inşa edilmiş gizlilik odaklı gizli oturum katmanı

---

## 📌 Parsİz Nedir?

Parsİz, Pardus 23'e **gizli oturum** özelliği ekler. Giriş ekranında ikincil bir şifre girildiğinde, LUKS şifreli bir konteyner açılır ve içeriği RAM'e yüklenir. Oturum tamamen bellekte çalışır — sistem kapandığında değişiklikler şifreli konteynere geri kaydedilir ve RAM'de veya loglarda hiçbir iz kalmaz.

| Giriş Şifresi | Sonuç |
|---------------|-------|
| Normal şifre | Standart Pardus masaüstü |
| Gizli şifre | Gizli masaüstü — veriler LUKS'tan RAM'e yüklenir |
| Yanlış şifre | Standart kimlik doğrulama hatası |

> **Dürüst kapsam:** Parsİz **güçlü şifreleme + amnezik RAM oturumu** sağlar. Tam inkar edilebilir şifreleme sistemi değildir — konteyner dosyası diskte görünür durmaktadır. Koruma modeli şudur: veriler dinlenme halinde güçlü şifrelemeyle korunur, kapanış sonrasında RAM'de iz kalmaz.

> **Yapay zekâ kullanımı:** Bu sistemi biz tasarladık. Yapay zekâyı araştırma ve bazı kod bloklarını hızlandırmak için kullandık, ancak sistem tasarımı ve entegrasyon tamamen bize aittir.

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
        └── Gizli Şifre
                │
                ▼
         parsiz-check.sh (PAM auth aşaması)
         cryptsetup open → LUKS konteyneri açıldı
         exit 0 → common-auth atlanır
                │
                ▼
         parsiz-pam.sh (PAM session aşaması)
         ├── LUKS → /mnt/luks_disk mount
         ├── tmpfs (RAM diski) → /mnt/secure_ram
         ├── rsync LUKS → RAM
         ├── LUKS umount
         └── RAM → /home/lenovo bind mount
                │
                ▼
         Gizli Masaüstü
         (Tüm veriler yalnızca RAM'de)
                │
                ▼
         Kapanış → parsiz-shutdown.sh
         ├── LUKS → /mnt/luks_disk mount
         ├── rsync RAM → LUKS (değişiklikleri kaydet)
         ├── umount /home/lenovo, /mnt/secure_ram, /mnt/luks_disk
         └── cryptsetup close (anahtar bellekten silindi)
```

---

## 🔐 Güvenlik Modeli

| Tehdit | Koruma | Notlar |
|--------|--------|--------|
| Uzaktan saldırı | ✅ Güçlü | LUKS şifreli konteyner |
| Fiziksel el koyma (kapalı) | ✅ Güçlü | Disk şifreli, anahtar diskte yok |
| Fiziksel zorlama | ⚠️ Kısmi | Normal şifre gerçek masaüstünü açar; konteyner dosyası görünür |
| Adli disk incelemesi | ✅ Güçlü | Gizli şifre olmadan konteyner okunamaz |
| RAM adli incelemesi (açık) | ⚠️ Kısmi | Oturum aktifken anahtar RAM'de |
| Cold boot saldırısı | ⚠️ Kısmi | Güç kesilmesinden sonra ~saniyeler |
| Uyku / Hibernate | ✅ Devre dışı | systemctl ile maskelendi |
| Swap | ✅ Devre dışı | Swap partition yok |
| Oturumdayken güç kesilmesi | ⚠️ Risk | Kaydedilmemiş değişiklikler kaybolur |

---

## 📁 Repo Yapısı

```
Parsİz/
├── README.md                    # İngilizce dokümantasyon
├── README.tr.md                 # Bu dosya (Türkçe)
├── install.sh                   # Otomatik kurulum scripti
├── scripts/
│   ├── parsiz-check.sh          # PAM auth: gizli şifrede LUKS açar
│   ├── parsiz-pam.sh            # PAM session: RAM ortamını mount eder
│   └── parsiz-shutdown.sh       # Kapanış: RAM → LUKS sync
├── config/
│   ├── lightdm.conf             # LightDM yapılandırması
│   ├── pam.lightdm              # PAM yapılandırması
│   └── stealth-sync.service     # systemd kapanış sync servisi
└── tests/
    ├── test_normal_login.md
    ├── test_hidden_login.md
    ├── test_persistence.md
    └── test_security.md
```

---

## ⚙️ Gereksinimler

- Pardus 23 XFCE (temiz kurulum)
- `cryptsetup` >= 2.6
- `rsync` >= 3.2
- Minimum 4 GB RAM
- Minimum 25 GB boş disk alanı

---

## 🚀 Kurulum

```bash
git clone https://github.com/ezgiefsa/ParsIz.git
cd Parz-z
sudo bash install.sh
```

---

## 🧪 Test Sonuçları

| Test | Beklenen | Durum |
|------|----------|-------|
| Normal giriş | Standart masaüstü, gizli iz yok | ✅ Geçti |
| Gizli giriş | Gizli masaüstü, RAM mount edildi | ✅ Geçti |
| Yanlış şifre | Kimlik doğrulama hatası | ✅ Geçti |
| Dosya kalıcılığı | Dosyalar yeniden başlatmada korunur | ✅ Geçti |
| Gizli sonrası normal giriş | Gizli dosyalar görünmüyor | ✅ Geçti |
| Hibernate denemesi | Engellendi | ✅ Geçti |
| Swap kontrolü | Aktif swap yok | ✅ Geçti |

---

## ⚠️ Bilinen Sınırlamalar

1. `/opt/system_data.img` konteyner dosyası diskte görünür — gizli birim değil
2. Gizli oturumda asla uyku/hibernate kullanma — sadece `sudo systemctl poweroff`
3. Gizli oturumda güç kesilmesi = kaydedilmemiş değişiklikler kaybolur
4. tmpfs boyutu sabit 4G — RAM kısıtlıysa ayarla

---

## 👥 Ekip

| İsim | Rol |
|------|-----|
| Ezgi Efsa Güleç | Proje Lideri & Baş Geliştirici |
| Ebubekir Yılmaz | Geliştirici |
| Fatma Zehra Osmanoğlu | Geliştirici |

---

*Parsİz — Güçlü şifreleme, amnezik oturumlar, Pardus'a özel.*
