# Parsİz — Amnesic Hidden Session for Pardus

> **TEKNOFEST 2026 — Pardus Development Category**  
> A privacy-focused hidden session layer built on Pardus 23 XFCE

---

## 📌 What is Parsİz?

Parsİz adds a **hidden session** capability to Pardus 23. When a secondary password is entered at login, a LUKS-encrypted container is opened and its contents are loaded into RAM. The session runs entirely in memory — when the system shuts down, changes are saved back to the encrypted container and no traces remain in RAM or logs.

| Login Password | Result |
|----------------|--------|
| Normal password | Standard Pardus desktop |
| Secret password | Hidden desktop — data loaded from LUKS into RAM |
| Wrong password | Standard authentication failure |

> **Honest scope:** Parsİz provides **strong encryption + amnesic RAM session**. It is not a full deniable encryption system (the container file is visible on disk). The protection model is: data is strongly encrypted at rest, and leaves no traces in RAM after shutdown.

> **AI usage note:** We designed this system ourselves. AI was used as a research assistant and to accelerate some code blocks. System architecture, integration, and all technical decisions are entirely our own work.

---

## 🏗️ Architecture

```
Login Screen (LightDM + GTK Greeter)
        │
        ▼
   PAM Auth Stack
        │
        ├── Normal Password ──────────────► Standard Pardus Desktop
        │                                   /home/lenovo (real disk)
        │
        └── Secret Password
                │
                ▼
         parsiz-check.sh (PAM auth phase)
         cryptsetup open → LUKS container unlocked
         exit 0 → common-auth skipped
                │
                ▼
         parsiz-pam.sh (PAM session phase)
         ├── Mount LUKS → /mnt/luks_disk
         ├── Create tmpfs (RAM disk) → /mnt/secure_ram
         ├── rsync LUKS → RAM
         ├── umount LUKS
         └── bind mount RAM → /home/lenovo
                │
                ▼
         Hidden Desktop
         (All data in RAM only)
                │
                ▼
         Shutdown → parsiz-shutdown.sh
         ├── Mount LUKS → /mnt/luks_disk
         ├── rsync RAM → LUKS (save changes)
         ├── umount /home/lenovo, /mnt/secure_ram, /mnt/luks_disk
         └── cryptsetup close (key wiped from memory)
```

---

## 🔐 Security Model

| Threat | Protection | Notes |
|--------|-----------|-------|
| Remote attack | ✅ Strong | LUKS encrypted container |
| Physical seizure (powered off) | ✅ Strong | Disk encrypted, key not on disk |
| Coercion (rubber-hose) | ⚠️ Partial | Normal password opens real desktop; container file is visible |
| Forensic disk analysis | ✅ Strong | Container unreadable without secret password |
| RAM forensics (powered on) | ⚠️ Partial | Key in RAM while session is active |
| Cold boot attack | ⚠️ Partial | RAM wipe window ~seconds after power off |
| Suspend / Hibernate | ✅ Disabled | Masked via systemctl |
| Swap | ✅ Disabled | No swap partition |
| Power cut during session | ⚠️ Risk | Unsaved changes lost (by design) |

---

## 📁 Repository Structure

```
Parsİz/
├── README.md                    # This file (English)
├── README.tr.md                 # Turkish documentation
├── install.sh                   # Automated installation script
├── scripts/
│   ├── parsiz-check.sh          # PAM auth: opens LUKS if secret password
│   ├── parsiz-pam.sh            # PAM session: mounts RAM environment
│   └── parsiz-shutdown.sh       # Shutdown: syncs RAM → LUKS, cleans up
├── config/
│   ├── lightdm.conf             # LightDM configuration (GTK greeter)
│   ├── pam.lightdm              # PAM configuration for LightDM
│   └── stealth-sync.service     # systemd service for shutdown sync
└── tests/
    ├── test_normal_login.md
    ├── test_hidden_login.md
    ├── test_persistence.md
    └── test_security.md
```

---

## ⚙️ Requirements

- Pardus 23 XFCE (fresh installation)
- `cryptsetup` >= 2.6
- `rsync` >= 3.2
- Minimum 4 GB RAM
- Minimum 25 GB free disk space

---

## 🚀 Installation

```bash
git clone https://github.com/ezgiefsa/ParsIz.git
cd Parz-z
sudo bash install.sh
```

---

## 🧪 Test Results

| Test | Expected | Status |
|------|----------|--------|
| Normal login | Standard desktop, no hidden traces | ✅ Pass |
| Secret login | Hidden desktop, RAM mounted | ✅ Pass |
| Wrong password | Auth failure | ✅ Pass |
| File persistence | Files survive reboot | ✅ Pass |
| Normal login after secret | Hidden files not visible | ✅ Pass |
| Hibernate attempt | Blocked | ✅ Pass |
| Swap check | No swap active | ✅ Pass |

---

## ⚠️ Known Limitations

1. Container file `/opt/system_data.img` is visible on disk — not a hidden volume
2. Never use sleep/suspend in hidden session — only `sudo systemctl poweroff`
3. Power cut during hidden session = unsaved changes lost
4. tmpfs size is fixed at 4G — adjust if RAM is limited

---

## 👥 Team

| Name | Role |
|------|------|
| Ezgi Efsa Güleç | Project Lead & Developer |
| Ebubekir Yılmaz | Developer |
| Fatma Zehra Osmanoğlu | Developer |

---

*Parsİz — Strong encryption, amnesic sessions, Pardus native.*
